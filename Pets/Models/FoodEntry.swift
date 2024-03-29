//
//  FoodEntry.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-21.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation
import CoreData

extension FoodEntry: BaseModel {
	static let recordType = "CD_FoodEntry"
	
	var wrappedDate: Date {
		self.date ?? Date()
	}
}
