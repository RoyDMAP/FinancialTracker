//
//  Extensions.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import Foundation

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
