import CloudKit
import SwiftUI

import Foundation
import SwiftUI
import UIKit
import CloudKit

/// This struct wraps a `UICloudSharingController` for use in SwiftUI.
struct CloudSharingView: UIViewControllerRepresentable {
	
	// MARK: - Properties
	@Environment(\.presentationMode) var presentationMode
	let share: CKShare
	let container: CKContainer
	let pet: Pet
	
	// MARK: - UIViewControllerRepresentable
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
	
	func makeUIViewController(context: Context) -> some UIViewController {
		let sharingController = UICloudSharingController(share: share, container: container)
		sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
		sharingController.delegate = context.coordinator
		sharingController.modalPresentationStyle = .formSheet
		return sharingController
	}
	
	func makeCoordinator() -> CloudSharingView.Coordinator {
		Coordinator(pet: pet)
	}
	
	final class Coordinator: NSObject, UICloudSharingControllerDelegate {
		let stack = CoreDataStack.shared
		let pet: Pet
		
		init(pet: Pet) {
			self.pet = pet
		}
		
		func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
			debugPrint("Error saving share: \(error)")
		}
		
		func itemTitle(for csc: UICloudSharingController) -> String? {
			pet.name
		}
		
		func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
			UIImage(named: "AppIcon")!.pngData()
		}
		
		func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
			print("Saved the share")
		}
		
		func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
			print("\(pet.wrappedName) was deleted on another device")
			
			if !stack.isOwner(object: pet) {
				stack.delete(pet)
			}
		}
	}
}
