//
//  User.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/8/25.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var emoji: String  
    
    init(id: UUID = UUID(), name: String, emoji: String = "👤") {
        self.id = id
        self.name = name
        self.emoji = emoji
    }
}
