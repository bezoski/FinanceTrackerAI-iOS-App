//
//  Item.swift
//  FinanceTrackerAI
//
//  Created by Rafał Buczkowski on 17/02/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
