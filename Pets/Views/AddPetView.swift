import SwiftUI
import PhotosUI

struct AddPetView: View {
	@Environment(\.managedObjectContext) var managedObjectContext
	@Environment(\.dismiss) private var dismiss
	
	@StateObject private var viewModel = ViewModel()
	
	private var stack = CoreDataStack.shared
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Name", text: $viewModel.name)
				} footer: {
					Text("Name is required")
						.font(.caption)
						.foregroundColor(viewModel.name.isBlank ? .red : .clear)
				}
				
				Section {
					if viewModel.image == nil {
						Button {
							viewModel.showingImagePicker = true
						} label: {
							Text("Add a photo")
						}
					}
					
					viewModel.image?
						.resizable()
						.scaledToFit()
				}
				
				DatePicker(
					"Birthday",
					selection: $viewModel.birthday.flatten(defaultValue: Date()),
					displayedComponents: [.date]
				)
				
				Section {
					Button {
						createNewPet()
						dismiss()
					} label: {
						Text("Save")
					}
					.disabled(!viewModel.isValid)
				}
			}
			.fullScreenCover(isPresented: $viewModel.showingImagePicker, onDismiss: loadImage) {
				ImagePicker(image: $viewModel.inputImage, sourceType: .camera)
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", action: { dismiss() })
				}
			}
			.navigationTitle("New Pet")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

// MARK: View Model
fileprivate extension AddPetView {
	@MainActor class ViewModel: ObservableObject {
		/// Form Inputs
		@Published var name = ""
		@Published var image: Image?
		@Published var birthday: Date?
		
		/// Image Picker
		@Published var inputImage: UIImage?
		@Published var showingImagePicker = false
		
		var isValid: Bool {
			return !name.isBlank
		}
	}
}


// MARK: Loading image and creating a new pet
extension AddPetView {
	private func loadImage() {
		guard let inputImage = viewModel.inputImage else { return }
		viewModel.image = Image(uiImage: inputImage)
	}
	
	private func createNewPet() {
		let pet = Pet(context: managedObjectContext)
		pet.id = UUID()
		pet.createdAt = Date.now
		pet.name = viewModel.name
		let imageData = viewModel.inputImage?.jpegData(compressionQuality: 0.8)
		pet.image = imageData
		
		stack.save()
	}
}

struct AddPetView_Previews: PreviewProvider {
	static var previews: some View {
		HStack {
			EmptyView()
		}.sheet(isPresented: .constant(true)) {
			AddPetView()
		}
	}
}
