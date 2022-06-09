import SwiftUI

struct EditPetView: View {
  let pet: Pet
  private var stack = CoreDataStack.shared
  private var hasInvalidData: Bool {
    return pet.name.isBlank ||
    pet.details.isBlank ||
    (pet.name == captionText && pet.details == detailsText)
  }

  @State private var captionText: String = ""
  @State private var detailsText: String = ""
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) var managedObjectContext

  init(pet: Pet) {
    self.pet = pet
  }

  var body: some View {
    NavigationView {
      VStack {
        VStack(alignment: .leading) {
          Text("Caption")
            .font(.caption)
            .foregroundColor(.secondary)
          TextField(text: $captionText) {}
            .textFieldStyle(.roundedBorder)
        }
        .padding(.bottom, 8)

        VStack(alignment: .leading) {
          Text("Details")
            .font(.caption)
            .foregroundColor(.secondary)
          TextEditor(text: $detailsText)
        }
      }
      .padding()
      .navigationTitle("Edit Pet")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            managedObjectContext.performAndWait {
              pet.name = captionText
              pet.details = detailsText
              stack.save()
              presentationMode.wrappedValue.dismiss()
            }
          } label: {
            Text("Save")
          }
          .disabled(hasInvalidData)
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Text("Cancel")
          }
        }
      }
    }
    .onAppear {
      captionText = pet.name
      detailsText = pet.details
    }
  }
}

// MARK: String
extension String {
  var isBlank: Bool {
    self.trimmingCharacters(in: .whitespaces).isEmpty
  }
}
