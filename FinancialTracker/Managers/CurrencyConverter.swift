//
//  CurrencyConverter.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/10/25.
//

import Foundation

class CurrencyConverter {
    static let shared = CurrencyConverter()
    
    // Exchange rates relative to USD (approximate rates)
    private let exchangeRates: [String: Double] = [
        "USD": 1.0,      // US Dollar (base)
        "MXN": 17.0,     // Mexican Peso
        "JPY": 150.0,    // Japanese Yen
        "SAR": 3.75      // Saudi Riyal (Arabic)
    ]
    
    // Get current locale's currency code
    var currentCurrencyCode: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        switch languageCode {
        case "es":
            return "MXN"  // Spanish → Mexican Peso
        case "ja":
            return "JPY"  // Japanese → Yen
        case "ar":
            return "SAR"  // Arabic → Saudi Riyal
        default:
            return "USD"  // English → US Dollar
        }
    }
    
    // Get currency symbol for current locale
    var currencySymbol: String {
        switch currentCurrencyCode {
        case "USD":
            return "$"
        case "MXN":
            return "$"    // Mexican Peso also uses $
        case "JPY":
            return "¥"
        case "SAR":
            return "﷼"    // Saudi Riyal symbol
        default:
            return "$"
        }
    }
    
    // Convert from USD to current locale currency
    func convertFromUSD(_ amountInUSD: Double) -> Double {
        let rate = exchangeRates[currentCurrencyCode] ?? 1.0
        return amountInUSD * rate
    }
    
    // Convert from current locale currency to USD (for saving)
    func convertToUSD(_ amountInLocalCurrency: Double) -> Double {
        let rate = exchangeRates[currentCurrencyCode] ?? 1.0
        return amountInLocalCurrency / rate
    }
    
    // Format currency with proper symbol and locale
    func format(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currentCurrencyCode
        formatter.maximumFractionDigits = currentCurrencyCode == "JPY" ? 0 : 2
        
        // Customize formatter based on currency
        switch currentCurrencyCode {
        case "JPY":
            formatter.currencySymbol = "¥"
        case "MXN":
            formatter.currencySymbol = "MX$"
        case "SAR":
            formatter.currencySymbol = "﷼"
        default:
            formatter.currencySymbol = "$"
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currencySymbol)\(amount)"
    }
    
    // Get exchange rate info for display
    func getExchangeRateInfo() -> String {
        let rate = exchangeRates[currentCurrencyCode] ?? 1.0
        if rate == 1.0 {
            return "1 USD = 1 USD"
        } else {
            return "1 USD = \(String(format: rate >= 10 ? "%.0f" : "%.2f", rate)) \(currentCurrencyCode)"
        }
    }
}
