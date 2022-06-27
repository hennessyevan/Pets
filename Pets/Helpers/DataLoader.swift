//
//  DataLoader.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-13.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation

public class DataLoader<DataType: Codable> {
	func parseJSON(_ resourcePath: String) -> DataType? {
		guard let url = Bundle.main.url(forResource: resourcePath, withExtension: "json") else {
			print("Could not find JSON file at path \(resourcePath)")
			return nil
		}
		
		do {
			let jsonData = try Data(contentsOf: url)
			let response = try JSONDecoder().decode(DataType.self, from: jsonData)
			return response
		} catch {
			return nil
		}
	}
}
