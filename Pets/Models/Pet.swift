import CoreData
import SwiftUI

extension Pet: BaseModel {
	static var all: NSFetchRequest<Pet> {
		let request = Pet.fetchRequest()
		request.sortDescriptors = []
		
		return request
	}
	
	#if DEBUG
	static var preview: Pet = {
		let _pet = Pet(context: CoreDataStack.shared.context)
		_pet.createdAt = Date.now
		_pet.birthday = Date(from: "2020-10-16")
		_pet.name = "Fido"
		
		_pet.foodEntryArray = []
		
		for days in 1...10 {
			let foodEntry: FoodEntry = FoodEntry(context: CoreDataStack.shared.context)
			foodEntry.date = Calendar.current.date(byAdding: .day, value: days * -1, to: Date())!
			try! foodEntry.save()
			
			_pet.foodEntryArray.insert(foodEntry, at: 0)
		}
		
		return _pet
	}()
	#endif
}

enum Sex: String, CaseIterable {
	case unknown
	case male
	case female
}

extension Pet {
	static let recordType = "CD_Pet"
	
	var wrappedName: String {
		self.name ?? ""
	}
	
	var uiImage: UIImage {
		UIImage(data: self.image ?? Data()) ?? UIImage()
	}
	
	var wrappedSex: Sex {
		get { Sex(rawValue: self.sex ?? "unknown")! }
		set(newSex) { self.sex = newSex.rawValue }
	}
	
	var foodEntryArray: [FoodEntry] {
		get {
			let set = foodEntries as? Set<FoodEntry> ?? []
			
			return set.sorted {
				$0.wrappedDate < $1.wrappedDate
			}
		}
		
		set(_foodEntryArray) {
			let set = NSSet(array: _foodEntryArray)
			self.foodEntries = set
		}
	}
}
