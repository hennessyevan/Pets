//
//  CloudKit++.swift
//  Pets
//
//  Created by Evan Hennessy on 2022-06-24.
//  Copyright © 2022 Evan Hennessy. All rights reserved.
//

import Foundation

public enum CKQueryNotificationReason: Int {
	case recordCreated

	case recordUpdated

	case recordDeleted
}
