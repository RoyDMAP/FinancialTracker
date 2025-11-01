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

struct Transaction: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var amount: Double
    var isIncome: Bool
    var date: Date  
}
