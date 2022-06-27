////
////  CloudKitSubscriptions.swift
////  Pets
////
////  Created by Evan Hennessy on 2022-06-27.
////  Copyright © 2022 Evan Hennessy. All rights reserved.
////
//
//import Foundation
//import CloudKit
//
///// Handles common methods for subscriptions across multiple databases
//enum CloudKitDatabaseSubscription: String {
//	case `private`
//	case `shared`
//}
//
//extension CloudKitDatabaseSubscription {
//	
//	var database: CKDatabase {
//		switch self {
//		case .private:
//			return CoreDataStack.shared.ckContainer.privateCloudDatabase
//		case .shared:
//			return CoreDataStack.shared.ckContainer.sharedCloudDatabase
//		}
//	}
//	
//	var subscription: CKSubscription {
//		let _subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
//		
//		let notificationInfo = CKSubscription.NotificationInfo()
//		notificationInfo.shouldSendContentAvailable = true
//		_subscription.notificationInfo = notificationInfo
//		
//		return _subscription
//	}
//	
//	var subscriptionID: String {
//		return "\(rawValue)SubscriptionIDKey"
//	}
//	
//	var changeToken: CKServerChangeToken? {
//		return UserDefaults.standard.object(forKey: changeTokenKey) as? CKServerChangeToken
//	}
//	
//	var saved: Bool {
//		return UserDefaults.standard.bool(forKey: savedSubscriptionKey)
//	}
//	
//	func set(_ changeToken: CKServerChangeToken?) {
//		UserDefaults.standard.set(changeToken, forKey: changeTokenKey)
//	}
//	
//	func saved(_ saved: Bool) {
//		UserDefaults.standard.set(saved, forKey: savedSubscriptionKey)
//	}
//	
//	private var changeTokenKey: String {
//		return "\(rawValue)DatabaseChangeTokenKey"
//	}
//	
//	private var savedSubscriptionKey: String {
//		return "\(rawValue)SavedSubscriptionKey"
//	}
//}
//
///// Provides a place to store and retrieve `CKServerChangeToken` objects related to a `CKRecordZone`
//struct RecordZoneChangeTokenProvider {
//	
//	private static var changeTokenKey: (CKRecordZone.ID) -> String = { recordZoneID in
//		return "\(recordZoneID.zoneName)ChangeTokenKey"
//	}
//	
//	static func getChangeToken(for recordZoneID: CKRecordZone.ID) -> CKServerChangeToken? {
//		return UserDefaults.standard.object(forKey: changeTokenKey(recordZoneID)) as? CKServerChangeToken
//	}
//	
//	static func set(_ changeToken: CKServerChangeToken?, for recordZoneID: CKRecordZone.ID) {
//		UserDefaults.standard.set(changeToken, forKey: changeTokenKey(recordZoneID))
//	}
//}
//
//// CloudKitSyncManager provides VERY BASIC methods to get you started pulling information
//// after receiving a remote notification.
//struct CloudKitSyncManager {
//	
//	// Create a database subscription to receive notifications for changes
//	static func create(databaseSubscription: CloudKitDatabaseSubscription) {
//		
//		// Don't save if it's already been saved
//		// Server will throw error
//		if databaseSubscription.saved { return }
//		
//		let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [databaseSubscription.subscription],
//																									 subscriptionIDsToDelete: nil)
//		
//		operation.modifySubscriptionsResultBlock = { result in
//			switch result {
//			case .failure(let error):
//				print("Error saving subscription: \(error.localizedDescription)")
//				return
//			case .success():
//				databaseSubscription.saved(true)
//			}
//		}
//		
//		databaseSubscription.database.add(operation)
//	}
//	
//	// Call in AppDelegate when
//	// application(_:didReceiveRemoteNotification:fetchCompletionHandler:)
//	static func fetchChanges(for subscription: CloudKitDatabaseSubscription) {
//		
//		// Create operation to fetch database changes
//		// Include previous changeToken if available
//		let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: subscription.changeToken)
//		
//		// Record Zone IDs to fetch updates for
//		var recordZoneIDs = [CKRecordZone.ID]()
//		
//		// Block called when a Record Zone is returned that has changes
//		operation.recordZoneWithIDChangedBlock = { recordZoneID in
//			recordZoneIDs.append(recordZoneID)
//		}
//		
//		operation.fetchDatabaseChangesResultBlock = { result in
//			switch result {
//			case .success(let serverResult):
//				subscription.set(serverResult.serverChangeToken)
//			case .failure(let error):
//				print(error.localizedDescription)
//			}
//		}
//		
//		subscription.database.add(operation)
//	}
//	
//	 //Fetch record changes for multiple recordZoneIDs
//		static func fetchChanges(for recordZoneIDs: [CKRecordZone.ID]) {
//	
//			if recordZoneIDs.isEmpty { return }
//	
//			// Create options for each record zone so that you can use a changeToken
//			var configurationsByRecordZone = [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration]()
//			for recordZoneID in recordZoneIDs {
//				let options = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
//				options.previousServerChangeToken = RecordZoneChangeTokenProvider.getChangeToken(for: recordZoneID)
//				return configurationsByRecordZone[recordZoneID] = options
//			}
//	
//			
//			let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: recordZoneIDs, configurationsByRecordZoneID: configurationsByRecordZone)
//	
//			// Add changed record to records array for processing at completion
//			operation.recordChangedBlock = { record in
//				debugPrint(["RECORD", record])
//			}
//	
//			// Add deleted recrod ID to array for processing at completion
////			operation.recordWithIDWasDeletedBlock = { recordID, _ in
////				recordIDsToDelete.append(recordID)
////			}
//	
//			// Save record zone changes
//			operation.recordZoneChangeTokensUpdatedBlock = { (recordZoneID, changeToken, _) in
//				RecordZoneChangeTokenProvider.set(changeToken, for: recordZoneID)
//			}
//	
//			// Called when an individual recordZone has completed
////			operation.recordZoneFetchCompletionBlock = { recordZoneID, changeToken, _, moreComing, error in
////
////				if let error = error {
////					print("Error fetching changes for record zone: \(error.localizedDescription)")
////				}
////
////				if moreComing {
////					RecordZoneChangeTokenProvider.set(changeToken, for: recordZoneID)
////					recordZoneIDsToTryAgain.append(recordZoneID)
////				}
////			}
//	
//			// Called when all the changes have been fetched
////			operation.fetchRecordZoneChangesCompletionBlock = { error in
////
////				if let error = error {
////					print("Error fetching Record Zone Changes: \(error.localizedDescription)")
////				}
////
////				// Let's still process changes we did receive even if there was an error
////				fetchChanges(for: recordZoneIDsToTryAgain)
////			}
//		}
//}
