//
//  PetFoodView.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-21.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import SwiftUI

struct PetFoodView: View {
	@ObservedObject var pet: Pet

	@State private var expanded = false

	var body: some View {
		Section {
			ForEach(pet.foodEntryArray.sorted(by: { a, b in
				a.wrappedDate > b.wrappedDate
			}).prefix(expanded ? 10 : 5), content: PetFoodItemView.init)
				.onDelete(perform: deleteFoodEntry)
				.animation(.spring(), value: pet.foodEntryArray)
		} header: {
			HStack {
				Label("Food", systemImage: "pawprint.fill")

				Spacer()

				if pet.foodEntryArray.count > 5 {
					Button(action: { withAnimation { expanded.toggle() } }) {
						Text(expanded ? "Less" : "More").font(.caption2)
					}
				}
			}
		}
		.listStyle(.insetGrouped)
	}
}

extension PetFoodView {
	private func deleteFoodEntry(at offsets: IndexSet) {
		pet.foodEntryArray.remove(atOffsets: offsets)

		try! pet.save()
	}
}

struct PetFoodItemView: View {
	@ObservedObject var foodEntry: FoodEntry

	var body: some View {
		VStack(alignment: .leading) {
			Text(DateFormatter.DATE_MEDIUM.string(from: foodEntry.wrappedDate))
				.font(.caption)

			if foodEntry.ownerName != nil {
				Text(foodEntry.ownerName!)
					.font(.caption2)
					.foregroundColor(.accentColor)
			}
		}.id(foodEntry.id)
	}
}

#if DEBUG
struct PetFoodView_Previews: PreviewProvider {
	static var previews: some View {
		List {
			PetFoodView(pet: Pet.preview)
		}
	}
}
#endif
