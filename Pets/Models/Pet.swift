import CoreData
import SwiftUI

extension Pet: BaseModel {
	static var all: NSFetchRequest<Pet> {
		let request = Pet.fetchRequest()
		request.sortDescriptors = []
		
		return request
	}
	
	#if DEBUG
	static var preview: Pet = {
		let _pet = Pet(context: CoreDataStack.shared.context)
		_pet.createdAt = Date.now
		_pet.birthday = Date(from: "2020-10-16")
		_pet.name = "Fido"
		
		_pet.foodEntryArray = []
		
		for days in 1...10 {
			let foodEntry: FoodEntry = FoodEntry(context: CoreDataStack.shared.context)
			foodEntry.date = Calendar.current.date(byAdding: .day, value: days * -1, to: Date())!
			foodEntry.ownerName = "Evan"
			try! foodEntry.save()
			
			_pet.foodEntryArray.insert(foodEntry, at: 0)
		}
		
		return _pet
	}()
	#endif
}

enum Sex: String, Equatable, CaseIterable {
	case unknown
	case male
	case female
	
	var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum Species: String, Equatable, CaseIterable {
	case unknown
	case dog
	case cat
	
	var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

extension Pet {
	static let recordType = "CD_Pet"
	
	var wrappedName: String {
		self.name ?? ""
	}
	
	var uiImage: UIImage {
		UIImage(data: self.image ?? Data()) ?? UIImage()
	}
	
	var wrappedSpecies: Species {
		get { Species(rawValue: self.species ?? "unknown")! }
		set(newSpecies) { self.species = newSpecies.rawValue }
	}
	
	var wrappedSex: Sex {
		get { Sex(rawValue: self.sex ?? "unknown")! }
		set(newSex) { self.sex = newSex.rawValue }
	}
	
	var foodEntryArray: [FoodEntry] {
		get {
			let set = foodEntries as? Set<FoodEntry> ?? []
			
			return set.sorted {
				$0.wrappedDate < $1.wrappedDate
			}
		}
		
		set(_foodEntryArray) {
			let set = NSSet(array: _foodEntryArray)
			self.foodEntries = set
		}
	}
	
	func sendNotification(message: String) -> Void {
		Task {
			await NotificationStack.shared.sendNotification(for: self, with: message)
		}
	}
}
