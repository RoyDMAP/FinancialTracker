//
//  AddTransactionView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

// Form to add a new transaction
struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss  // Lets us close this popup
    @Binding var transactions: [Transaction]  // List of all transactions
    
    @State private var title = ""  // Transaction name
    @State private var amount = ""  // Transaction amount
    @State private var isIncome = false  // Income or expense?
    @State private var date = Date()  // Transaction date
    @State private var showError = false  // Show error message?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section("Transaction Details") {
                        // Type in the name
                        TextField("Title", text: $title)
                        // Type in the amount
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        // Pick a date
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        // Switch to choose Income or Expense
                        Toggle("Income", isOn: $isIncome)
                    }
                    
                    // Show error message if amount is invalid
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
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Save button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Try to convert amount text to a number
                        if let amountValue = Double(amount) {
                            // Success! Create the transaction
                            let transaction = Transaction(
                                title: title,
                                amount: amountValue,
                                isIncome: isIncome,
                                date: date
                            )
                            // Add it to the list
                            transactions.append(transaction)
                            // Close the popup
                            dismiss()
                        } else {
                            // Failed - show error message
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
    AddTransactionView(transactions: .constant([]))
}
