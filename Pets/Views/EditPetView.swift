import SwiftUI

public struct EditPetView: View {
	public let pet: Pet
	
	/// Form Inputs
	@State var name = ""
	@State var image: Image?
	@State var birthday: Date?
	
	/// Image Picker
	@State private var inputImage: UIImage?
	@State private var showingImagePicker = false
	
	@State private var showingDeleteConfirmation = false

  private var stack = CoreDataStack.shared

  @Environment(\.dismiss) var dismiss
  @Environment(\.managedObjectContext) var managedObjectContext
	
	public init(pet: Pet) {
		self.pet = pet
	}

  public var body: some View {
		NavigationStack {
			Form {
						
						Section {
							TextField("Name", text: $name, prompt: Text("Name"))
						} header: {
							Text("Name")
						} footer: {
							Text("Name is required")
								.font(.caption)
								.foregroundColor(name.isBlank ? .red : .clear)
						}
				
				Section {
					Button("Delete \(pet.name)") {
						showingDeleteConfirmation = true
					}
				}
						
				}
			.confirmationDialog("Delete \(pet.name)", isPresented: $showingDeleteConfirmation) {
				Button("Delete", role: .destructive) {
					stack.delete(pet)
					dismiss()
				}
			}
			.navigationTitle("Edit \(pet.name)")
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button {
							save()
						} label: {
							Text("Save")
						}
						.disabled(!isValid)
					}
					ToolbarItem(placement: .navigationBarLeading) {
						Button {
							dismiss()
						} label: {
							Text("Cancel")
						}
					}
				}
			.onAppear {
				name = pet.name
			}
		}
  }
	
	var isValid: Bool {
		return !name.isBlank
	}
	
	func save() {
		managedObjectContext.performAndWait {
			pet.name = name
			stack.save()
			dismiss()
		}
	}
}


struct EditPetView_Previews: PreviewProvider {
	static var pet = {
		let _pet = Pet(context: CoreDataStack.shared.context)
		_pet.id = UUID()
		_pet.createdAt = Date.now
		_pet.name = "Fido"
		_pet.details = "Hello"
		return _pet
	}()
	
	static var previews: some View {
		HStack {
			EmptyView()
		}.sheet(isPresented: .constant(true)) {
			EditPetView(pet: pet)
		}
	}
}
