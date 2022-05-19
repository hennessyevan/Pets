import SwiftUI

struct HomeView: View {
  @State private var showAddDestinationSheet = false
  @Environment(\.managedObjectContext) var managedObjectContext
  @FetchRequest(sortDescriptors: [SortDescriptor(\.createdAt, order: .reverse)])
  var destinations: FetchedResults<Destination>
  private let stack = CoreDataStack.shared

  var body: some View {
    NavigationView {
      // swiftlint:disable trailing_closure
      VStack {
        List {
          ForEach(destinations, id: \.objectID) { destination in
            NavigationLink(destination: DestinationDetailView(destination: destination)) {
              HStack {
                VStack(alignment: .leading) {
                  Image(uiImage: UIImage(data: destination.image ?? Data()) ?? UIImage())
                    .resizable()
                    .scaledToFill()

                  Text(destination.caption)
                    .font(.title3)
                    .foregroundColor(.primary)

                  Text(destination.details)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                                
                  if stack.isShared(object: destination) {
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
                  stack.delete(destination)
                } label: {
                  Label("Delete", systemImage: "trash")
                }.disabled(!stack.canDelete(object: destination))
            }
          }
        }
        Spacer()
        Button {
          showAddDestinationSheet.toggle()
        } label: {
          Text("Add Pet")
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom, 8)
      }
      .emptyState(destinations.isEmpty, emptyContent: {
        VStack {
          Text("No pets yet")
            .font(.headline)
          Button {
            showAddDestinationSheet.toggle()
          } label: {
            Text("Add Pet")
          }
          .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 120)
        .padding(.vertical, 30)
        .background(Color(uiColor: UIColor.systemGray4))
        .cornerRadius(10)
      })
      .sheet(isPresented: $showAddDestinationSheet, content: {
        AddDestinationView()
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
