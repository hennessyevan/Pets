import SwiftUI

struct AddDestinationView: View {
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
          Text("Birthday")
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
            createNewDestination()
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

// MARK: Loading image and creating a new destination
extension AddDestinationView {
  private func loadImage() {
    guard let inputImage = inputImage else { return }
    image = Image(uiImage: inputImage)
  }

  private func createNewDestination() {
    let destination = Destination(context: managedObjectContext)
    destination.id = UUID()
    destination.createdAt = Date.now
    destination.caption = caption
    destination.details = details
    let imageData = inputImage?.jpegData(compressionQuality: 0.8)
    destination.image = imageData
    stack.save()
  }
}

struct AddDestinationView_Previews: PreviewProvider {
  static var previews: some View {
    AddDestinationView()
  }
}
