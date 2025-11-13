//
//  EditTransactionView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.locale) var locale  // Detects locale changes
    @Binding var transactions: [Transaction]
    let transaction: Transaction
    let onSave: () -> Void
    
    @State private var title: String
    @State private var amount: String
    @State private var isIncome: Bool
    @State private var date: Date
    @State private var showError = false
    
    init(transactions: Binding<[Transaction]>, transaction: Transaction, onSave: @escaping () -> Void) {
        self._transactions = transactions
        self.transaction = transaction
        self.onSave = onSave
        
        // Initialize with transaction's local currency amount
        _title = State(initialValue: transaction.title)
        _amount = State(initialValue: String(format: "%.2f", transaction.localAmount))
        _isIncome = State(initialValue: transaction.isIncome)
        _date = State(initialValue: transaction.date)
    }
    
    var body: some View {
        let theme = AppTheme.current
        let currencySymbol = CurrencyConverter.shared.currencySymbol
        
        return NavigationStack {
            ZStack {
                ThemedBackground(theme: theme)
                
                Form {
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
                                    Text("Editing as:")
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
            .navigationTitle(NSLocalizedString("edit_transaction", comment: "Edit Transaction"))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                CulturalButtonRow(
                    primaryTitle: NSLocalizedString("save", comment: "Save"),
                    primaryAction: {
                        if let amountValue = Double(amount) {
                            // Convert from local currency to USD before saving
                            let amountInUSD = CurrencyConverter.shared.convertToUSD(amountValue)
                            
                            // Find and update the transaction
                            if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                                transactions[index].title = title
                                transactions[index].amountUSD = amountInUSD  // Update USD amount
                                transactions[index].isIncome = isIncome
                                transactions[index].date = date
                            }
                            
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

