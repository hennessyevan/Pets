import SwiftUI
import PhotosUI
import CoreData
import FormValidator

struct AddPetView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.managedObjectContext) var context
	
	@StateObject private var formState = AddPetForm()
	
	@State var showingSourceTypePicker = false
	@State var showingImagePicker = false
	@State var photoPickerSourceType: UIImagePickerController.SourceType = .camera
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					ProfileImageView(
						editing: true,
						name: formState.name,
						image: formState.inputImage,
						onAdd: { showingSourceTypePicker = true }
					)
				}
				.listRowBackground(Color.clear)
				
				TextField("Name", text: $formState.name)
					.validation(formState.nameValidation)
				
				DatePicker(
					"Birthday",
					selection: $formState.birthday.flatten(defaultValue: Date()),
					in: formState.birthdateRange,
					displayedComponents: [.date]
				)
				
				HStack {
					Text("Sex")
					Spacer()
					Picker("Sex", selection: $formState.sex) {
						Text(Sex.male.rawValue.capitalized).tag(Sex.male)
						Text(Sex.female.rawValue.capitalized).tag(Sex.female)
					}
					.frame(width: 200)
					.pickerStyle(.segmented)
				}
				
			}
			.confirmationDialog("Add Photo", isPresented: $showingSourceTypePicker) {
				Button("Camera") { pickSourceType(.camera) }
				Button("Photo Library") { pickSourceType(.photoLibrary) }
			}
			.fullScreenCover(isPresented: $showingImagePicker, onDismiss: { loadImage() }) {
				ImagePicker(image: $formState.inputImage, sourceType: photoPickerSourceType)
					.background(photoPickerSourceType == .camera ? Color.black : nil)
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", action: { dismiss() })
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("Save", action: {
						savePet()
						dismiss()
					})
					.disabled(!formState.form.allValid)
				}
			}
			.navigationTitle("New Pet")
			.navigationBarTitleDisplayMode(.inline)
			.interactiveDismissDisabled(formState.form.allValid)
		}
	}
}


class AddPetForm: ObservableObject {
	
	@Published var name: String = ""
	lazy var nameValidation: ValidationContainer = {
		$name.nonEmptyValidator(form: form, errorMessage: "Name is required")
	}()
	
	@Published var birthday: Date?
	var birthdateRange: ClosedRange<Date> {
		let min = Calendar.current.date(byAdding: .year, value: -35, to: Date())!
		let max = Date()
		return min...max
	}
	
	@Published var sex: Sex = .unknown
	
	@Published var image: Image?
	@Published var inputImage: UIImage?
	
	lazy var form = {
		FormValidation(validationType: .immediate)
	}()
}

extension AddPetView {
	func savePet() {
		do {
			let pet = Pet(context: context)
			pet.name = formState.name
			pet.birthday = formState.birthday
			pet.wrappedSex = formState.sex
			
			try pet.save()
		} catch {
			print(error)
		}
	}
	
	func loadImage() {
		guard let inputImage = formState.inputImage else { return }
		formState.image = Image(uiImage: inputImage)
	}
	
	func pickSourceType(_ sourceType: UIImagePickerController.SourceType) {
		photoPickerSourceType = sourceType
		showingImagePicker = true
	}
}

struct AddPetView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			EmptyView()
		}.sheet(isPresented: .constant(true)) {
			AddPetView()
		}
	}
}
