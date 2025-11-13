//
//  LocaleInfoView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/10/25.
//

import SwiftUI
import Combine

struct LocaleInfoView: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Sample number to format
    let sampleNumber: Double = 1234567.89
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: Date())
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: currentTime)
    }
    
    var formattedNumber: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: sampleNumber)) ?? ""
    }
    
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: sampleNumber)) ?? ""
    }
    
    var currentLocaleInfo: String {
        let locale = Locale.current
        let languageCode = locale.language.languageCode?.identifier ?? "Unknown"
        let regionCode = locale.region?.identifier ?? "Unknown"
        let currencyCode = locale.currency?.identifier ?? "Unknown"
        
        return """
        Language: \(languageCode)
        Region: \(regionCode)
        Currency: \(currencyCode)
        """
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(NSLocalizedString("current_locale", comment: "Current Locale")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentLocaleInfo)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        LocalizedImageView(imageName: "flag")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                }
                
                Section(NSLocalizedString("date_format", comment: "Date Format")) {
                    HStack {
                        Text(NSLocalizedString("today", comment: "Today"))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formattedDate)
                            .fontWeight(.medium)
                    }
                }
                
                Section(NSLocalizedString("time_format", comment: "Time Format")) {
                    HStack {
                        Text(NSLocalizedString("current_time", comment: "Current Time"))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formattedTime)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                
                Section(NSLocalizedString("number_format", comment: "Number Format")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(NSLocalizedString("decimal", comment: "Decimal"))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formattedNumber)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text(NSLocalizedString("currency", comment: "Currency"))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formattedCurrency)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section {
                    Text(NSLocalizedString("format_info", comment: "These formats change based on your device's language and region settings."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(NSLocalizedString("locale_info", comment: "Locale Information"))
            .onReceive(timer) { _ in
                currentTime = Date()
            }
        }
    }
}

#Preview {
    LocaleInfoView()
}
