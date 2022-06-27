//
//  PetRowView.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-16.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import SwiftUI

struct PetRowView: View {
	let pet: Pet
	
	var body: some View {
		NavigationLink(destination: PetDetailView(pet: pet)) {
			HStack(alignment: .center, spacing: 20) {
				Image(uiImage: pet.uiImage)
					.resizable()
					.frame(width: 75, height: 75, alignment: .center)
					.background(Color.gray.opacity(0.2))
					.scaledToFill()
					.cornerRadius(.infinity)
				
				VStack(alignment: .center) {
					Text(pet.wrappedName)
						.font(.title3)
						.foregroundColor(Color.accentColor)
				}
			}
		}
	}
}


struct PetRowView_Previews: PreviewProvider {
    static var previews: some View {
			PetsListView()
		}
}
