import CoreData
import CloudKit
import UIKit

final class CoreDataStack: ObservableObject {
	static let shared = CoreDataStack()
	var context: NSManagedObjectContext {
		persistentContainer.viewContext
	}
	
	var privatePersistentStore: NSPersistentStore {
		guard let privateStore = _privatePersistentStore else {
			fatalError("Private store is not set")
		}
		return privateStore
	}
	
	var sharedPersistentStore: NSPersistentStore {
		guard let sharedStore = _sharedPersistentStore else {
			fatalError("Shared store is not set")
		}
		return sharedStore
	}
	
	lazy var persistentContainer: NSPersistentCloudKitContainer = {
		let container = NSPersistentCloudKitContainer(name: "Pets")
		
		guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
			fatalError("Unable to get persistentStoreDescription")
		}
		let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
		privateStoreDescription.url = storesURL?.appendingPathComponent("private.sqlite")
		
		let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
		guard let sharedStoreDescription = privateStoreDescription.copy() as? NSPersistentStoreDescription else {
			fatalError("Copying the private store description returned an unexpected value.")
		}
		sharedStoreDescription.url = sharedStoreURL
		
		guard let containerIdentifier = privateStoreDescription.cloudKitContainerOptions?.containerIdentifier else {
			fatalError("Unable to get containerIdentifier")
		}
		let sharedStoreOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
		sharedStoreOptions.databaseScope = .shared
		sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
		
		container.persistentStoreDescriptions.append(sharedStoreDescription)
		
		// Sets up history tracking
		privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
		privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
		
		container.loadPersistentStores { loadedStoreDescription, error in
			if let error = error as NSError? {
				fatalError("Failed to load persistent stores: \(error)")
			} else if let cloudKitContainerOptions = loadedStoreDescription
				.cloudKitContainerOptions {
				guard let loadedStoreDescritionURL = loadedStoreDescription.url else {
					return
				}
				if cloudKitContainerOptions.databaseScope == .private {
					let privateStore = container.persistentStoreCoordinator
						.persistentStore(for: loadedStoreDescritionURL)
					self._privatePersistentStore = privateStore
				} else if cloudKitContainerOptions.databaseScope == .shared {
					let sharedStore = container.persistentStoreCoordinator
						.persistentStore(for: loadedStoreDescritionURL)
					self._sharedPersistentStore = sharedStore
				}
			}
		}
		
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		container.viewContext.automaticallyMergesChangesFromParent = true
		
		return container
	}()
	
	var ckContainer: CKContainer {
		let storeDescription = persistentContainer.persistentStoreDescriptions.first
		guard let identifier = storeDescription?.cloudKitContainerOptions?.containerIdentifier else {
			fatalError("Unable to get container identifier")
		}
		
		return CKContainer(identifier: identifier)
	}
	
	private var _privatePersistentStore: NSPersistentStore?
	private var _sharedPersistentStore: NSPersistentStore?
}

// MARK: Check if an object is already shared
extension CoreDataStack {	
	private func isShared(objectID: NSManagedObjectID) -> Bool {
		var isShared = false
		if let persistentStore = objectID.persistentStore {
			if persistentStore == sharedPersistentStore {
				isShared = true
			} else {
				let container = persistentContainer
				do {
					let shares = try container.fetchShares(matching: [objectID])
					if shares.first != nil {
						isShared = true
					}
				} catch {
					print("Failed to fetch share for \(objectID): \(error)")
				}
			}
		}
		
		return isShared
	}
	
	func isShared(object: NSManagedObject) -> Bool {
		isShared(objectID: object.objectID)
	}
	
	func isOwner(object: NSManagedObject) -> Bool {
		guard isShared(object: object) else { return true }
		guard let share = try? persistentContainer.fetchShares(matching: [object.objectID]) [object.objectID] else {
			print("Couldn't get CKShare")
			return false
		}
		
		if let currentUser = share.currentUserParticipant, currentUser == share.owner {
			return true
		}
		
		return false
	}
	
	func getShare(_ pet: Pet) -> CKShare? {
		guard isShared(object: pet) else { return nil }
		
		guard let shareDictionary = try? persistentContainer.fetchShares(matching: [pet.objectID]), let share = shareDictionary[pet.objectID] else {
			print("Unable to get CKShare")
			return nil
		}
		
		share[CKShare.SystemFieldKey.title] = pet.name
		return share
	}
	
	func canUpdate(object: NSManagedObject) -> Bool {
		if (isShared(object: object)) {
			return persistentContainer.canUpdateRecord(forManagedObjectWith: object.objectID)
		} else {
			return true
		}
	}
	
	func canDelete(object: NSManagedObject) -> Bool {
		if (isShared(object: object)) {
			return persistentContainer.canDeleteRecord(forManagedObjectWith: object.objectID)
		} else {
			return true
		}
	}
	
	func isICloudAvailable() -> Bool {
		if let _ = FileManager.default.ubiquityIdentityToken {
			return true
		}
		
		return false
	}
}

// MARK: Save or delete from Core Data
extension CoreDataStack {
	func save() {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				print("ViewContext save error: \(error)")
			}
		}
	}
	
	func delete(_ object: NSManagedObject) {
		context.perform {
			self.context.delete(object)
			self.save()
		}
	}
}
