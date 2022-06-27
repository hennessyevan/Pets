import SwiftUI

public struct EditPetView: View {
	@Environment(\.dismiss) var dismiss
	
	@ObservedObject var pet: Pet
	@StateObject var form = EditPetForm()
	
	@State private var showingImagePicker = false
	@State private var showingDeleteConfirmation = false
	
	public var body: some View {
		Form {
			Section {
				TextField("Name", text: $form.name, prompt: Text("Name"))
			} header: {
				Text("Name")
			} footer: {
				Text("Name is required")
					.font(.caption)
					.foregroundColor(form.name.isBlank ? .red : .clear)
			}
			
			Section {
				Button("Delete \(form.name)", role: .destructive) {
					showingDeleteConfirmation = true
				}
			}
			
		}
//		.toolbar {
//			ToolbarItem(placement: .navigationBarTrailing) {
//				Button {
//					form.save()
//				} label: {
//					Text("Save")
//				}
//				.disabled(!form.isValid)
//			}
//			ToolbarItem(placement: .navigationBarLeading) {
//				Button {
//					dismiss()
//				} label: {
//					Text("Cancel")
//				}
//			}
//		}
		.confirmationDialog("Delete \(form.name)", isPresented: $showingDeleteConfirmation) {
			Button("Delete", role: .destructive) {
				try! pet.delete()
				dismiss()
			}
		}
		.navigationTitle("Edit \(form.name)")
	}
}

@MainActor class EditPetForm: ObservableObject {
	@Published var name: String
	
	init(name: String = "") {
		self.name = name
	}
}


struct EditPetView_Previews: PreviewProvider {
	static var previews: some View {
		HStack {
			EmptyView()
		}.sheet(isPresented: .constant(true)) {
			EditPetView(pet: Pet.preview)
		}
	}
}
