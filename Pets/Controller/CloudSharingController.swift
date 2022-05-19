import CloudKit
import SwiftUI

struct CloudSharingView: UIViewControllerRepresentable {
  let share: CKShare
  let container: CKContainer
  let destination: Destination

  func makeCoordinator() -> CloudSharingCoordinator {
    CloudSharingCoordinator(destination: destination)
  }

  func makeUIViewController(context: Context) -> UICloudSharingController {

    share[CKShare.SystemFieldKey.title] = destination.caption

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
  let destination: Destination
  init(destination: Destination) {
    self.destination = destination
  }

  func itemTitle(for csc: UICloudSharingController) -> String? {
    destination.caption
  }

  func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
    print("Failed to save share: \(error)")
  }

  func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
    print("Saved the share")
  }

  func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
    if !stack.isOwner(object: destination) {
      stack.delete(destination)
    }
  }
}
