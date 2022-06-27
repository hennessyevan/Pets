import SwiftUI
import CoreData

struct PetsListView: View {
	@State private var addingPet = false
	
	@FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)]) var pets: FetchedResults<Pet>
	
	var body: some View {
		NavigationView {
			VStack {
				if pets.count > 0 {
					List {
						ForEach(pets) { pet in
							PetRowView(pet: pet)
						}
					}
				} else {
					VStack {
						Text("Add your pet")
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
				}
			}
			.sheet(isPresented: $addingPet) { AddPetView() }
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

struct PetsListView_Previews: PreviewProvider {
	static var previews: some View {
		PetsListView()
	}
}
