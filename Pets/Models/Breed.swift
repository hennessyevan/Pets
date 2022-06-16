struct DogBreed: Codable, Identifiable {
	let id: String
	let name: String
	let group: String
}

// Loading Dog Breeds
extension DogBreed {
	static func load() -> [DogBreed?] {
		let loader = DataLoader<[DogBreed]>()
		guard let breeds = loader.parseJSON("DogBreeds") else {
			print("Couldn't load dog breeds")
			return []
		}
		return breeds
	}
}
