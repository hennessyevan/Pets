//
//  View+Extensions.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-15.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation
import SwiftUI

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
