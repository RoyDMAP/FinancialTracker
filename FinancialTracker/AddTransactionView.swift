//
//  AddTransactionView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transactions: [Transaction]
    let onSave: () -> Void
    
    @State private var title = ""
    @State private var amount = ""
    @State private var isIncome = false
    @State private var date = Date()
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.opacity(0.05)
                    .ignoresSafeArea()
                
                Form {
                    // NEW: Description Section
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("transaction_description", comment: "Track your income and expenses easily"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                // Quick fill example
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
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section(NSLocalizedString("transaction_details", comment: "Transaction Details")) {
                        TextField(NSLocalizedString("title", comment: "Title"), text: $title)
                        TextField(NSLocalizedString("amount", comment: "Amount"), text: $amount)
                            .keyboardType(.decimalPad)
                        DatePicker(NSLocalizedString("date", comment: "Date"), selection: $date, displayedComponents: .date)
                        Toggle(NSLocalizedString("income", comment: "Income"), isOn: $isIncome)
                    }
                    
                    if showError {
                        Section {
                            Text(NSLocalizedString("error_invalid_amount", comment: "Please enter a valid number for amount"))
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(NSLocalizedString("add_transaction", comment: "Add Transaction"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save", comment: "Save")) {
                        if let amountValue = Double(amount) {
                            let transaction = Transaction(
                                title: title,
                                amount: amountValue,
                                isIncome: isIncome,
                                date: date
                            )
                            transactions.append(transaction)
                            onSave()
                            dismiss()
                        } else {
                            showError = true
                        }
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddTransactionView(transactions: .constant([]), onSave: {})
}
