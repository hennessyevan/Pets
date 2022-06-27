////
////  AppDelegate+Notifications.swift
////  Pets
////
////  Created by Evan Hennessy on 2022-06-25.
////  Copyright © 2022 Evan Hennessy. All rights reserved.
////
//
//import Foundation
//import CoreData
//import CloudKit
//import SwiftUI
//import UserNotifications
//import Combine
//
//extension AppDelegate: UNUserNotificationCenterDelegate {
//	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//		UIApplication.shared.registerForRemoteNotifications()
//		
//		registerForPushNotifications()
//		
//		UNUserNotificationCenter.current().delegate = self
//		
//		// Creates a private database subscription to listen for changes
//		CloudKitDatabaseSubscription.private.saved(false)
//		CloudKitSyncManager.create(databaseSubscription: .private)
//		
//		return true
//	}
//	
//	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//		
//		completionHandler(.newData)
//		
//		guard let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) else { return }
//		
//		guard let subscriptionID = cloudKitNotification.subscriptionID else {
//			print("Received a remote notification for unknown subscriptionID")
//			return
//		}
//		
//		switch subscriptionID {
//		case CloudKitDatabaseSubscription.private.rawValue:
//			CloudKitSyncManager.fetchChanges(for: .private)
//		case CloudKitDatabaseSubscription.shared.rawValue:
//			CloudKitSyncManager.fetchChanges(for: .shared)
//		default: break
//		}
//	}
//	
//	/// Capture notifications while app is open
//	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//		debugPrint(["notification", notification])
//		completionHandler([.banner])
//	}
//	
//	// MARK: Notification Registration
//	func registerForPushNotifications() {
//		UNUserNotificationCenter.current()
//			.requestAuthorization(options: [.badge, .alert, .sound, .carPlay]) { [weak self] granted, _ in
//				print("Notification permission granted: \(granted)")
//				guard granted else { return }
//				self?.getNotificationSettings()
//			}
//	}
//	
//	func getNotificationSettings() {
//		UNUserNotificationCenter.current().getNotificationSettings { settings in
//			print("Notification settings: \(settings)")
//			
//			guard settings.authorizationStatus == .authorized else { return }
//			DispatchQueue.main.async {
//				UIApplication.shared.registerForRemoteNotifications()
//			}
//		}
//	}
//}
