//
//  String.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-05-26.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation

extension String: Identifiable {
	public var id: String {
		self
	}
}

extension String {
	var isBlank: Bool {
		self.trimmingCharacters(in: .whitespaces).isEmpty
	}
}
