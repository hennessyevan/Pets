import SwiftUI

struct AddPetView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) var managedObjectContext

  @State private var caption: String = ""
  @State private var details: String = ""
  @State private var inputImage: UIImage?
  @State private var image: Image?
  @State private var showingImagePicker = false
  private var stack = CoreDataStack.shared

  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Name", text: $caption)
        } footer: {
          Text("Name is required")
            .font(.caption)
            .foregroundColor(caption.isBlank ? .red : .clear)
        }
      

        Section {
          TextEditor(text: $details)
        } header: {
          Text("Breed")
        } footer: {
          Text("Birthday is required")
            .font(.caption)
            .foregroundColor(details.isBlank ? .red : .clear)
        }

        Section {
          if image == nil {
            Button {
              self.showingImagePicker = true
            } label: {
              Text("Add a photo")
            }
          }

          image?
            .resizable()
            .scaledToFit()
        }
        Section {
          Button {
            createNewPet()
            presentationMode.wrappedValue.dismiss()
          } label: {
            Text("Save")
          }
          .disabled(caption.isBlank || details.isBlank)
        }
      }
      .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
        ImagePicker(image: $inputImage)
      }
      .navigationTitle("Add Pet")
    }
  }
}

// MARK: Loading image and creating a new pet
extension AddPetView {
  private func loadImage() {
    guard let inputImage = inputImage else { return }
    image = Image(uiImage: inputImage)
  }

  private func createNewPet() {
    let pet = Pet(context: managedObjectContext)
    pet.id = UUID()
    pet.createdAt = Date.now
    pet.caption = caption
    pet.details = details
    let imageData = inputImage?.jpegData(compressionQuality: 0.8)
    pet.image = imageData
    stack.save()
  }
}

struct AddPetView_Previews: PreviewProvider {
  static var previews: some View {
    AddPetView()
  }
}
