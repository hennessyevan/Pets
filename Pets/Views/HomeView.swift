import SwiftUI

struct HomeView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @State private var addingPet = false
  
  @FetchRequest(sortDescriptors: [SortDescriptor(\.createdAt, order: .reverse)])
  
  var pets: FetchedResults<Pet>
  private let stack = CoreDataStack.shared
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
					ForEach(pets, id: \.id) { pet in
						PetRowView(pet: pet)
					}
        }
      }
      .emptyState(pets.isEmpty, emptyContent: {
        VStack {
          Text("No pets yet")
            .font(.headline)
          Button {
            addingPet = true
          } label: {
            Text("Add Pet")
          }
          .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 120)
        .padding(.vertical, 30)
        .background(Color(uiColor: UIColor.systemGray6))
        .cornerRadius(10)
      })
      .sheet(isPresented: $addingPet, content: {
        AddPetView()
      })
			.toolbar {
				ToolbarItem(placement: .automatic) {
					Button(action: { addingPet = true }) {
						Image(systemName: "plus")
					}
				}
			}
      .navigationTitle("Pets")
    }
  }
}

struct PetRowView: View {
	let pet: Pet
	
	var body: some View {
		NavigationLink(destination: PetDetailView(pet: pet)) {
			
			Button(action: {  }) {
				HStack(spacing: 20) {
					Image(uiImage: UIImage(data: pet.image ?? Data()) ?? UIImage())
						.resizable()
						.frame(width: 75, height: 75, alignment: .center)
						.background(Color.gray.opacity(0.2))
						.scaledToFill()
						.cornerRadius(.infinity)
					
					VStack(alignment: .center) {
						Text(pet.name)
							.font(.title3)
							.foregroundColor(Color("AccentColor"))
						
						if !pet.details.isEmpty {
							Text(pet.details)
								.font(.callout)
								.foregroundColor(.secondary)
								.multilineTextAlignment(.leading)
						}
					}
				}
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
			.environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
  }
}
