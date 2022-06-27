//
//  ProfileImageView.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-21.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import SwiftUI

struct ProfileImageView: View {
	var editing: Bool = false
	var name: String = ""
	var image: UIImage?
	
	var onAdd: (() -> Void) = {}
	
    var body: some View {
			VStack {
				if image == nil {
					if name.isEmpty {
						Image(systemName: "person.crop.circle.fill")
							.foregroundColor(Color.gray)
							.font(.system(size: 80))
							.imageScale(.large)
					} else {
						ZStack {
							Circle()
								.fill(Color.gray)
								.frame(width: 100, height: 100, alignment: .center)
							
							Text(name.prefix(1))
								.font(.system(size: 50, design: .rounded).weight(.semibold))
								.foregroundColor(.white)
								.shadow(color: .black.opacity(0.12), radius: 2)
						}
					}
				} else {
					Image(uiImage: image ?? UIImage())
						.resizable()
						.frame(width: 100, height: 100, alignment: .center)
						.scaledToFit()
						.clipShape(Circle())
				}
				
				if editing {
					Button("Add photo", action: { self.onAdd() })
				}
			}.centeredHorizontally()
    }
}

struct ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
			ProfileImageView(image: UIImage(named: "Evan"))
					.previewLayout(.fixed(width: 200, height: 200))
					.previewDevice(.none)
    }
}
