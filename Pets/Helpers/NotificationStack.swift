//
//  Notification.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-07-02.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import CloudKit
import Foundation

public class NotificationStack {
	static let shared = NotificationStack()
	
	let stack = CoreDataStack.shared
	let database = CoreDataStack.shared.ckContainer.publicCloudDatabase

	private func fetchOrCreateNotificationRecord(pet: Pet) async -> CKRecord? {
		do {
			guard let petCKRecord = stack.persistentContainer.record(for: pet.objectID) else {
				print("Couldn't find CKRecord for \(pet.wrappedName)")
				return nil
			}
			
			print("Got CKRecord for \(pet.wrappedName)")
			
			let notificationRecord = CKRecord(recordType: "Notification", recordID: CKRecord.ID(recordName: petCKRecord.recordID.recordName))
			notificationRecord["pet"] = petCKRecord.recordID.recordName
			
			let result = try await database.modifyRecords(saving: [notificationRecord], deleting: [], savePolicy: .allKeys)
			let savedNotificationRecord = try? result.saveResults.first?.1.get()
			
			return savedNotificationRecord
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
	
	func fetchOrCreatePetNotificationRecord(pet: Pet) async -> CKRecord? {
		let newNotificationRecord = await fetchOrCreateNotificationRecord(pet: pet)
		return newNotificationRecord
	}
	
	func sendNotification(for pet: Pet, with message: String) async {
		if let petNotificationRecord = await fetchOrCreatePetNotificationRecord(pet: pet) {
			print(petNotificationRecord.recordID.recordName)
			petNotificationRecord["message"] = message
			petNotificationRecord["modifiedTime"] = Date.now
			
			do {
				_ = try await database.modifyRecords(saving: [petNotificationRecord], deleting: [], savePolicy: .changedKeys)
				print("updated notification")
			} catch {
				print(error.localizedDescription)
			}
		}
	}
}
