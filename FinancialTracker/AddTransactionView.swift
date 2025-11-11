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
                    Section("transaction_details") {
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
            .navigationTitle("add_transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
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
