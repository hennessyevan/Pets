//
//  BaseModel.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-16.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation
import CoreData

protocol BaseModel {
	static var viewContext: NSManagedObjectContext { get }
	func save() throws
	func delete() throws
}

extension BaseModel where Self: NSManagedObject {
	static var viewContext: NSManagedObjectContext {
		CoreDataStack.shared.context
	}
	
	func save() throws {
		try Self.viewContext.save()
	}
	
	func delete() throws {
		Self.viewContext.delete(self)
		try save()
	}
}
