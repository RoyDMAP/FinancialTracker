//
//  Transaction.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//
// Import Foundation for basic data types like Date and UUID
//
//  Transaction.swift
//  FinancialTracker
//

import Foundation

// Data model for a transaction
struct Transaction: Identifiable, Hashable {
    var id = UUID()  // Unique ID
    var title: String  // Name (e.g., "Groceries")
    var amount: Double  // Dollar amount
    var isIncome: Bool  // True = income, False = expense
    var date: Date  // When it happened
}
