//
//  ExportManager.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 12/01/25.
//

import Foundation

class ExportManager {
    
    func exportToCSV(transactions: [Transaction]) -> String {
        var csv = "Title,Amount,Type,Date\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        for transaction in transactions {
            let title = transaction.title
            let amount = String(format: "%.2f", transaction.amountUSD)
            let type = transaction.isIncome ? "Income" : "Expense"
            let date = dateFormatter.string(from: transaction.date)
            
            csv += "\(title),\(amount),\(type),\(date)\n"
        }
        
        return csv
    }
}
