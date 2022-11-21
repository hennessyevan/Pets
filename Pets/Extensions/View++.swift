//
//  View++.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-17.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import FormValidator
import Foundation
import SwiftUI

extension View {
	func centeredHorizontally() -> some View {
		HStack {
			Spacer()
			self
			Spacer()
		}
	}
}
