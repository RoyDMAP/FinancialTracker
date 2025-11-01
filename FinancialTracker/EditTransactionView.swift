//
//  EditTransactionView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transactions: [Transaction]
    let transaction: Transaction
    let onSave: () -> Void  // Save function
    
    @State private var title: String
    @State private var amount: String
    @State private var isIncome: Bool
    @State private var date: Date
    @State private var showError = false
    
    init(transactions: Binding<[Transaction]>, transaction: Transaction, onSave: @escaping () -> Void) {
        self._transactions = transactions
        self.transaction = transaction
        self.onSave = onSave
        self._title = State(initialValue: transaction.title)
        self._amount = State(initialValue: String(transaction.amount))
        self._isIncome = State(initialValue: transaction.isIncome)
        self._date = State(initialValue: transaction.date)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
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
            .navigationTitle("Edit Transaction")
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
                            if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                                transactions[index] = Transaction(
                                    id: transaction.id,
                                    title: title,
                                    amount: amountValue,
                                    isIncome: isIncome,
                                    date: date
                                )
                            }
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
    EditTransactionView(
        transactions: .constant([]),
        transaction: Transaction(title: "Groceries", amount: 150, isIncome: false, date: Date()),
        onSave: {}
    )
}
