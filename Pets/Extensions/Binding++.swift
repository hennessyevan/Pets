//
//  Binding+Extensions.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-15.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation
import SwiftUI

public extension Binding where Value: Equatable {
	init(_ source: Binding<Value>, deselectTo value: Value) {
		self.init(get: { source.wrappedValue },
		          set: { source.wrappedValue = $0 == source.wrappedValue ? value : $0 })
	}
}

public extension Binding where Value == Date? {
	func flatten(defaultValue: Date) -> Binding<Date> {
		Binding<Date>(
			get: { wrappedValue ?? defaultValue },
			set: {
				wrappedValue = $0
			}
		)
	}
}
