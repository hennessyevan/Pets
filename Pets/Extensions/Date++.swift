//
//  DateFormatter+Extensions.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-16.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation

extension DateFormatter {
	static let yyyyMMdd: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.calendar = Calendar(identifier: .iso8601)
		return formatter
	}()
	
	static let DATE_MEDIUM: DateFormatter = {
		let formatter = DateFormatter()
		formatter.setLocalizedDateFormatFromTemplate("dd MMM YYYY")
		formatter.calendar = Calendar(identifier: .iso8601)
		return formatter
	}()
}

extension Date {
		init?(from yyyyMMdd: String?) {
			if yyyyMMdd == nil { return nil }
				guard let date = DateFormatter.yyyyMMdd.date(from: yyyyMMdd!) else { return nil }
				self.init(timeInterval: 0, since: date)
		}

		init(from yyyyMMdd: String) {
				let date = DateFormatter.yyyyMMdd.date(from: yyyyMMdd)!
				self.init(timeInterval: 0, since: date)
		}
}
