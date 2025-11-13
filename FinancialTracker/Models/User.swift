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
    var photoData: Data?  //Store photo as Data
    
    init(id: UUID = UUID(), name: String, emoji: String, photoData: Data? = nil) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.photoData = photoData
    }
}
