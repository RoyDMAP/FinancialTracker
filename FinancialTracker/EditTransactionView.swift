//
//  EditTransactionView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

// Form to edit an existing transaction
struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transactions: [Transaction]
    let transaction: Transaction  // The transaction we're editing
    
    @State private var title: String
    @State private var amount: String
    @State private var isIncome: Bool
    @State private var date: Date
    @State private var showError = false
    
    // Set up the form with the transaction's current info
    init(transactions: Binding<[Transaction]>, transaction: Transaction) {
        self._transactions = transactions
        self.transaction = transaction
        self._title = State(initialValue: transaction.title)
        self._amount = State(initialValue: String(transaction.amount))
        self._isIncome = State(initialValue: transaction.isIncome)
        self._date = State(initialValue: transaction.date)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section("Transaction Details") {
                        // Change the name
                        TextField("Title", text: $title)
                        // Change the amount
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        // Change the date
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        // Change Income/Expense
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
            .navigationTitle("Edit Transaction")
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
                            // Find the transaction in the list
                            if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                                // Update it with new info
                                transactions[index] = Transaction(
                                    id: transaction.id,
                                    title: title,
                                    amount: amountValue,
                                    isIncome: isIncome,
                                    date: date
                                )
                            }
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
    EditTransactionView(
        transactions: .constant([]),
        transaction: Transaction(
            title: "Groceries",
            amount: 150,
            isIncome: false,
            date: Date()
        )
    )
}
