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
    let onSave: () -> Void  // Save function
    
    @State private var title = ""
    @State private var amount = ""
    @State private var isIncome = false
    @State private var date = Date()
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section("Transaction Details") {
                        TextField("Title", text: $title)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        Toggle("Income", isOn: $isIncome)
                    }
                    
                    if showError {
                        Section {
                            Text("Please enter a valid number for amount")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountValue = Double(amount) {
                            let transaction = Transaction(
                                title: title,
                                amount: amountValue,
                                isIncome: isIncome,
                                date: date
                            )
                            transactions.append(transaction)
                            onSave()  // Save data
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
