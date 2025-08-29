//
//  Item.swift
//  UalaCities
//
//  Created by César Rosales on 29/08/2025.
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
