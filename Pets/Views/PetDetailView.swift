import CloudKit
import SwiftUI

struct PetDetailView: View {
  @ObservedObject var pet: Pet
  @State private var share: CKShare?
  @State private var showShareSheet = false
  @State private var showEditSheet = false
  private let stack = CoreDataStack.shared

  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 4) {
          if let imageData = pet.image, let image = UIImage(data: imageData) {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
          }
          Text(pet.name)
            .font(.headline)
          Text(pet.details)
            .font(.subheadline)
          Text(pet.createdAt.formatted(date: .abbreviated, time: .shortened))
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(.bottom, 8)
        }
      }

      if let share = share {
        Section {
          ForEach(share.participants, id: \.self) { participant in
            VStack(alignment: .leading) {
              Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
                .font(.headline)
              Text("Acceptance Status: \(string(for: participant.acceptanceStatus))")
                .font(.subheadline)
              Text("Role: \(string(for: participant.role))")
                .font(.subheadline)
              Text("Permissions: \(string(for: participant.permission))")
                .font(.subheadline)
            }
            .padding(.bottom, 8)
          }
        } header: {
          Text("Shared With")
        }
      }
    }
    .sheet(isPresented: $showShareSheet, content: {
      if let share = share {
        CloudSharingView(
          share: share,
          container: stack.ckContainer,
          pet: pet
        )
      }
    })
    .sheet(isPresented: $showEditSheet, content: {
      EditPetView(pet: pet)
    })
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        if (stack.canUpdate(object: pet)) {
          Button {
            showEditSheet.toggle()
          } label: {
            Text("Edit")
          }
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          if !stack.isShared(object: pet) {
            Task {
              await createShare(pet)
            }
          }
          showShareSheet = true
        } label: {
          Image(systemName:
            stack.isShared(object: pet)
              ? "person.crop.circle.fill.badge.checkmark"
              : "person.crop.circle.badge.plus"
          )
        }
      }
    }
    .onAppear(perform: {
      self.share = stack.getShare(pet)
    })
  }
}

// MARK: Returns CKShare participant permission
extension PetDetailView {
  private func string(for permission: CKShare.ParticipantPermission) -> String {
    switch permission {
    case .unknown:
      return "Unknown"
    case .none:
      return "None"
    case .readOnly:
      return "Read-Only"
    case .readWrite:
      return "Read-Write"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.Permission")
    }
  }

  private func string(for role: CKShare.ParticipantRole) -> String {
    switch role {
    case .owner:
      return "Owner"
    case .privateUser:
      return "Private User"
    case .publicUser:
      return "Public User"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.Role")
    }
  }

  private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
    switch acceptanceStatus {
    case .accepted:
      return "Accepted"
    case .removed:
      return "Removed"
    case .pending:
      return "Invited"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
    }
  }
  
  private func createShare(_ pet: Pet) async {
    do {
      let (_, share, _) = try await stack.persistentContainer.share([pet], to: nil)
      share[CKShare.SystemFieldKey.title] = pet.name
      self.share = share
    } catch {
      print("Failed to create share")
    }
  }
}

struct PetDetailView_Preview: PreviewProvider {
  static var pet = {
    let _pet = Pet(context: CoreDataStack.shared.context)
    _pet.id = UUID()
    _pet.createdAt = Date.now
    _pet.name = "Fido"
    _pet.details = "Hello"
    return _pet
  }()
  
  static var previews: some View {
  
    
    return PetDetailView(pet: pet)
  }
}
