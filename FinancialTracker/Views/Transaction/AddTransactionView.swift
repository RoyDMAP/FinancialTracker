//
//  AddTransactionView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.locale) var locale  // Detects locale changes
    @Binding var transactions: [Transaction]
    let onSave: () -> Void
    
    @State private var title = ""
    @State private var amount = ""
    @State private var isIncome = false
    @State private var date = Date()
    @State private var showError = false
    
    var body: some View {
        let theme = AppTheme.current
        let currencySymbol = CurrencyConverter.shared.currencySymbol
        
        return NavigationStack {
            ZStack {
                ThemedBackground(theme: theme)
                
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("transaction_description", comment: "Track your income and expenses easily"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                title = NSLocalizedString("example_transaction", comment: "Groceries")
                                amount = "50.00"
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text(NSLocalizedString("try_example", comment: "Try an Example"))
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.primaryColor)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(theme.cardBackground)
                    
                    Section(NSLocalizedString("transaction_details", comment: "Transaction Details")) {
                        TextField(NSLocalizedString("title", comment: "Title"), text: $title)
                        
                        // Currency input with auto-updating symbol
                        HStack {
                            Text(currencySymbol)
                                .foregroundColor(.secondary)
                                .font(.headline)
                                .id(locale)  // Force refresh when locale changes
                            
                            TextField(NSLocalizedString("amount", comment: "Amount"), text: $amount)
                                .keyboardType(.decimalPad)
                        }
                        
                        DatePicker(NSLocalizedString("date", comment: "Date"), selection: $date, displayedComponents: .date)
                        Toggle(NSLocalizedString("income", comment: "Income"), isOn: $isIncome)
                        
                        // Live preview of what's being entered
                        if !amount.isEmpty, let value = Double(amount) {
                            VStack(alignment: .leading, spacing: 8) {
                                Divider()
                                
                                HStack {
                                    Text("You're entering:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(CurrencyConverter.shared.format(value))
                                        .font(.caption)
                                        .foregroundColor(theme.primaryColor)
                                        .fontWeight(.semibold)
                                }
                                
                                HStack {
                                    Text("Will be saved as:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    let usdAmount = CurrencyConverter.shared.convertToUSD(value)
                                    Text("$\(String(format: "%.2f", usdAmount)) USD")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                                
                                Divider()
                            }
                            .padding(.vertical, 4)
                        }
                        
                        // Exchange rate info
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(CurrencyConverter.shared.getExchangeRateInfo())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listRowBackground(theme.cardBackground)
                    
                    if showError {
                        Section {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(NSLocalizedString("error_invalid_amount", comment: "Please enter a valid number for amount"))
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        .listRowBackground(theme.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(NSLocalizedString("add_transaction", comment: "Add Transaction"))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                CulturalButtonRow(
                    primaryTitle: NSLocalizedString("save", comment: "Save"),
                    primaryAction: {
                        if let amountValue = Double(amount) {
                            // Convert from local currency to USD before saving
                            let amountInUSD = CurrencyConverter.shared.convertToUSD(amountValue)
                            
                            let transaction = Transaction(
                                title: title,
                                amount: amountInUSD,  // Save in USD
                                isIncome: isIncome,
                                date: date
                            )
                            transactions.append(transaction)
                            onSave()
                            dismiss()
                        } else {
                            showError = true
                        }
                    },
                    secondaryTitle: NSLocalizedString("cancel", comment: "Cancel"),
                    secondaryAction: {
                        dismiss()
                    },
                    primaryRole: nil
                )
                .padding()
                .background(theme.cardBackground)
                .disabled(title.isEmpty || amount.isEmpty)
            }
        }
    }
}

#Preview {
    AddTransactionView(transactions: .constant([]), onSave: {})
}
