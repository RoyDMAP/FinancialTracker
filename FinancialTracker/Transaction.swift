//
//  Transaction.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//
// Import Foundation for basic data types like Date and UUID
import Foundation

// Define a Transaction struct to hold transaction data
// Identifiable: Allows SwiftUI to track each transaction uniquely
// Hashable: Required for NavigationSplitView selection tracking
struct Transaction: Identifiable, Hashable {
    // Unique identifier for each transaction (auto-generated)
    var id = UUID()
    
    // The name/description of the transaction (e.g., "Groceries")
    var title: String
    
    // The dollar amount of the transaction
    var amount: Double
    
    // True if this is income, false if it's an expense
    var isIncome: Bool
    
    // When the transaction occurred
    var date: Date
}
