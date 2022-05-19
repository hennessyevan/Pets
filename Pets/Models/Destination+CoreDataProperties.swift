import CoreData

// MARK: Fetch request and managed object properties
extension Pet {
  @nonobjc
  public class func fetchRequest() -> NSFetchRequest<Pet> {
    return NSFetchRequest<Pet>(entityName: "Pet")
  }

  @NSManaged public var name: String
  @NSManaged public var caption: String
  @NSManaged public var createdAt: Date
  @NSManaged public var details: String
  @NSManaged public var id: UUID
  @NSManaged public var image: Data?
}

// MARK: Identifiable
extension Pet: Identifiable {
}
