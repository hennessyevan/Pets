import CoreData

// MARK: Fetch request and managed object properties
extension Destination {
  @nonobjc
  public class func fetchRequest() -> NSFetchRequest<Destination> {
    return NSFetchRequest<Destination>(entityName: "Destination")
  }

  @NSManaged public var name: String
  @NSManaged public var caption: String
  @NSManaged public var createdAt: Date
  @NSManaged public var details: String
  @NSManaged public var id: UUID
  @NSManaged public var image: Data?
}

// MARK: Identifiable
extension Destination: Identifiable {
}
