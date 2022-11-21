//
//  AppDelegate+Notifications.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-25.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import CloudKit
import Combine
import CoreData
import Foundation
import SwiftUI
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		UIApplication.shared.registerForRemoteNotifications()
		
		Task {
			#if DEBUG && !targetEnvironment(simulator)
			await deleteSubscriptions()
			#endif
			createSubscription()
		}
		
		registerForPushNotifications()
		
		UNUserNotificationCenter.current().delegate = self
		
		return true
	}
	
	func deleteSubscriptions() async {
		let subscriptions = try? await CoreDataStack.shared.ckContainer.publicCloudDatabase.allSubscriptions()
		for subscription in subscriptions! {
			try! await CoreDataStack.shared.ckContainer.publicCloudDatabase.deleteSubscription(withID: subscription.subscriptionID)
			print("Deleted \(subscription.subscriptionID)")
		}
		UserDefaults.standard.setValue(false, forKey: "didCreateFeedSubscription")
	}
	
	func createSubscription() {
		guard !UserDefaults.standard.bool(forKey: "didCreateFeedSubscription") else { return }
		
		let subscription = CKQuerySubscription(recordType: "Notification", predicate: NSPredicate(value: true), subscriptionID: "notification-description", options: [.firesOnRecordUpdate, .firesOnRecordCreation])
						
		let notificationInfo = CKQuerySubscription.NotificationInfo()
		notificationInfo.titleLocalizationKey = "%1$@"
		notificationInfo.titleLocalizationArgs = ["message"]
		notificationInfo.alertLocalizationKey = "%1$@"
		notificationInfo.alertLocalizationArgs = ["modifiedTime"]
		
		notificationInfo.desiredKeys = ["message", "modifiedTime"]
		subscription.notificationInfo = notificationInfo
						
		// Create an operation that saves the subscription to the server.
		let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
		
		operation.perSubscriptionSaveBlock = { _, result in
			switch result {
			case .success(let subscription):
				print("Saved subscription \(subscription.subscriptionID)")
				UserDefaults.standard.setValue(true, forKey: "didCreateFeedSubscription")
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
						
		// Set an appropriate QoS and add the operation to the private
		// database's operation queue to execute it.
		operation.qualityOfService = .utility
		
		CoreDataStack.shared.ckContainer.publicCloudDatabase.add(operation)
	}
	
	/// Capture notifications while app is open
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner])
	}
	
	// MARK: Notification Registration

	func registerForPushNotifications() {
		UNUserNotificationCenter.current()
			.requestAuthorization(options: [.badge, .alert, .sound, .carPlay]) { [weak self] granted, _ in
				print("Notification permission granted: \(granted)")
				guard granted else { return }
				self?.getNotificationSettings()
			}
	}
	
	func getNotificationSettings() {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			print("Notification settings: \(settings)")
			
			guard settings.authorizationStatus == .authorized else { return }
			DispatchQueue.main.async {
				UIApplication.shared.registerForRemoteNotifications()
			}
		}
	}
}
