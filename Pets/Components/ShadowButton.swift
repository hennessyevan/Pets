//
//  ActionButton.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-09-02.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import SwiftUI

struct ShadowButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(.horizontal, 24)
			.padding(.vertical, 12)
			.background(.black)
			.foregroundColor(.white)
			.font(.body.weight(.medium))
			.cornerRadius(10)
			.shadow(color: .darkGray.opacity(0.24), radius: configuration.isPressed ? 2 : 4, x: 0, y: configuration.isPressed ? 2 : 4)
			.scaleEffect(configuration.isPressed ? 0.95 : 1)
			.animation(.easeOut(duration: 0.1), value: configuration.isPressed)
	}
}

struct ShadowButton_Previews: PreviewProvider {
	static var previews: some View {
		Button("Press Me") {
			print("Button pressed!")
		}
		.buttonStyle(ShadowButtonStyle())
	}
}
