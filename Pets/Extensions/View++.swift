//
//  View++.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-17.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation
import SwiftUI
import FormValidator

extension View {
	func centeredHorizontally() -> some View {
		HStack {
			Spacer()
			self
			Spacer()
		}
	}
}

