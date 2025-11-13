//
//  Transaction.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var amountUSD: Double  // Always stored in USD
    var isIncome: Bool
    var date: Date
    
    init(id: UUID = UUID(), title: String, amount: Double, isIncome: Bool, date: Date) {
        self.id = id
        self.title = title
        self.amountUSD = amount
        self.isIncome = isIncome
        self.date = date
    }
    
    // Get amount in current locale's currency
    var localAmount: Double {
        return CurrencyConverter.shared.convertFromUSD(amountUSD)
    }
    
    // Get formatted amount in current locale's currency
    var formattedAmount: String {
        return CurrencyConverter.shared.format(localAmount)
    }
}
