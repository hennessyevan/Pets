import SwiftUI
import Helm

struct HomeView: View {
  @State private var showAddPetSheet = false
  @State private var screen: String? = nil
  
  @Environment(\.managedObjectContext) var managedObjectContext
  @EnvironmentObject private var _helm: Helm<RoutesFragment>
  
  @FetchRequest(sortDescriptors: [SortDescriptor(\.createdAt, order: .reverse)])
  
  
  var pets: FetchedResults<Pet>
  private let stack = CoreDataStack.shared
  
  var body: some View {
    NavigationView {
      VStack {
        List {
          ForEach(pets, id: \.objectID) { pet in
            NavigationLink(destination: PetDetailView(pet: pet), isActive: _helm.isPresented(.pet, id: pet.id.uuidString)) {
              
              Button(action: { screen = pet.id.uuidString }) {
                HStack {
                  VStack(alignment: .leading) {
                    Image(uiImage: UIImage(data: pet.image ?? Data()) ?? UIImage())
                      .resizable()
                      .scaledToFill()
                    
                    Text(pet.caption)
                      .font(.title3)
                      .foregroundColor(.primary)
                    
                    Text(pet.details)
                      .font(.callout)
                      .foregroundColor(.secondary)
                      .multilineTextAlignment(.leading)
                    
                    if stack.isShared(object: pet) {
                      Image(systemName: "person.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                    }
                  }
                }
              }
              .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                  stack.delete(pet)
                } label: {
                  Label("Delete", systemImage: "trash")
                }.disabled(!stack.canDelete(object: pet))
              }
            }
          }
          
        }
        
        Spacer()
        Button {
          showAddPetSheet.toggle()
        } label: {
          Text("Add Pet")
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom, 8)
      }
      .emptyState(pets.isEmpty, emptyContent: {
        VStack {
          Text("No pets yet")
            .font(.headline)
          Button {
            showAddPetSheet.toggle()
          } label: {
            Text("Add Pet")
          }
          .buttonStyle(.borderedProminent)
          .accentColor(.primary)
        }
        .padding(.horizontal, 120)
        .padding(.vertical, 30)
        .background(Color(uiColor: UIColor.systemGray6))
        .cornerRadius(10)
      })
      .sheet(isPresented: $showAddPetSheet, content: {
        AddPetView()
      })
      .navigationTitle("Pets")
      .navigationViewStyle(.stack)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}

// MARK: Custom view modifier
extension View {
  func emptyState<EmptyContent>(_ isEmpty: Bool, emptyContent: @escaping () -> EmptyContent) -> some View where EmptyContent: View {
    modifier(EmptyStateViewModifier(isEmpty: isEmpty, emptyContent: emptyContent))
  }
}

struct EmptyStateViewModifier<EmptyContent>: ViewModifier where EmptyContent: View {
  var isEmpty: Bool
  let emptyContent: () -> EmptyContent
  
  func body(content: Content) -> some View {
    if isEmpty {
      emptyContent()
    } else {
      content
    }
  }
}
