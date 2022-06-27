import CloudKit
import SwiftUI
import SystemColors

struct PetDetailView: View {
	@Environment(\.managedObjectContext) var context
	@Environment(\.dismiss) var dismiss
	
	
	@ObservedObject var pet: Pet
	
	@State private var share: CKShare?
	
	@State private var showShareSheet = false
	@State private var showEditSheet = false
	@State private var loadingShare = false
	
	private let stack = CoreDataStack.shared
	
	var body: some View {
		List {
			ProfileImageView(name: pet.wrappedName, image: (pet.image != nil) ? pet.uiImage : nil)
				.listRowBackground(Color.clear)
			
			Section {
				HStack {
					Button(action: { withAnimation { addFoodEntry() } }) {
						Label("Feed", systemImage: "plus")
					}
					.buttonStyle(.bordered)
				}.centeredHorizontally()
			}
			.listRowSeparator(.hidden)
			.listRowBackground(Color.clear)
			
			PetFoodView(pet: pet)
			
			if let birthday = pet.birthday {
				Section {
					Text(DateFormatter.DATE_MEDIUM.string(from: birthday))
				} header: {
					Label("Birthday", systemImage: "gift")
				}
			}
			
			Button("Delete", role: .destructive, action: {
				try! pet.delete()
				dismiss()
			})
			
			if let share {
				Section {
					ForEach(share.participants, id: \.self) { participant in
						VStack(alignment: .leading) {
							Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
								.font(.subheadline)
							Text("\(string(for: participant.acceptanceStatus))\(string(for: participant.permission))")
								.font(.caption)
						}
						.listRowSeparator(.hidden)
						.font(.caption)
						.foregroundColor(.gray)
						.padding(.bottom, 8)
					}
				} header: {
					Text("Shared With")
				}.listRowBackground(Color.clear)
			}
			
		}
		.sheet(isPresented: $showShareSheet, content: {
			if let share {
				CloudSharingView(
					share: share,
					container: stack.ckContainer,
					pet: pet
				)
			}
		})
		.navigationTitle(pet.wrappedName)
		.listStyle(.insetGrouped)
		.sheet(isPresented: $showEditSheet, content: {
			//			EditPetView(pet: viewModel.pet)
		})
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				if (canUpdate) {
					Button("Edit", action: { showEditSheet.toggle() })
				}
			}
			
			ToolbarItem(placement: .navigationBarTrailing) {
				if stack.isICloudAvailable() {
					Button {
						Task {
							try? await sharePet(pet: pet)
						}
					} label: {
						if loadingShare {
							ProgressView()
						} else {
							Image(systemName:
											isShared
										? "person.crop.circle.fill.badge.checkmark"
										: "person.crop.circle.badge.plus"
							)
						}
					}
				}
			}
		}
//		.onAppear {
//			self.share = stack.getShare(pet)
//		}
	}
	
	private func sharePet(pet: Pet) async throws {
		loadingShare = true
		
		do {
			await fetchOrCreateShare(pet)
			loadingShare = false
		}
	}
}

// MARK: Returns CKShare participant permission strings
extension PetDetailView {
	private func string(for permission: CKShare.ParticipantPermission) -> String {
		switch permission {
		case .unknown:
			return "Unknown"
		case .none:
			return "None"
		case .readOnly:
			return "Read Only"
		case .readWrite:
			return "Read & Write"
		@unknown default:
			fatalError("A new value added to CKShare.Participant.Permission")
		}
	}
	
	private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
		return acceptanceStatus == .pending ? " - Pending" : ""
	}
	
	private func fetchOrCreateShare(_ pet: Pet) async {
		if self.share != nil {
			self.showShareSheet = true
			return
		}
		
		self.loadingShare = true
		
		do {
			let (_, share, _) = try await stack.persistentContainer.share([pet], to: nil)
			share[CKShare.SystemFieldKey.title] = pet.name
			self.share = share
			self.loadingShare = false
			self.showShareSheet = true
		} catch {
			print("Failed to create share")
			self.loadingShare = false
		}
	}
	
	private func addFoodEntry() {
		do {
			let foodEntry = FoodEntry(context: context)
			foodEntry.date = Date.now
			
			pet.addToFoodEntries(foodEntry)
			try pet.save()
		}
		catch {
			print("Failed to add food entry")
		}
	}
	
	var canUpdate: Bool {
		stack.canUpdate(object: pet)
	}
	
	var isShared: Bool {
		stack.isShared(object: pet)
	}
}

struct PetDetailView_Preview: PreviewProvider {
	static var previews: some View {
		return NavigationView {
			PetDetailView(pet: Pet.preview)
		}
	}
}
