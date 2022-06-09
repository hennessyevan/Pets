import CloudKit
import SwiftUI

struct CloudSharingView: UIViewControllerRepresentable {
  let share: CKShare
  let container: CKContainer
  let pet: Pet

  func makeCoordinator() -> CloudSharingCoordinator {
    CloudSharingCoordinator(pet: pet)
  }

  func makeUIViewController(context: Context) -> UICloudSharingController {

    share[CKShare.SystemFieldKey.title] = pet.name

    let controller = UICloudSharingController(share: share, container: container)
    controller.modalPresentationStyle = .formSheet
    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
  }
}

final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
  let stack = CoreDataStack.shared
  let pet: Pet
  init(pet: Pet) {
    self.pet = pet
  }

  func itemTitle(for csc: UICloudSharingController) -> String? {
    pet.name
  }

  func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
    print("Failed to save share: \(error)")
  }

  func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
    print("Saved the share")
  }

  func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
    if !stack.isOwner(object: pet) {
      stack.delete(pet)
    }
  }
}
