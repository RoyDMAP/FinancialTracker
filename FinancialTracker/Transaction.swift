//
//  Transaction.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import Foundation

struct Transaction: Identifiable, Hashable, Codable {
    var id = UUID()  // Unique ID
    var title: String  // Name (e.g., "Groceries")
    var amount: Double  // Dollar amount
    var isIncome: Bool  // True = income, False = expense
    var date: Date  // When it happened
}
