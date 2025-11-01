//
//  ContentView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.


import SwiftUI

struct ContentView: View {
    // This holds all our transactions (starts empty now)
    @State private var transactions: [Transaction] = []
    
    // This remembers which transaction we clicked on
    @State private var selectedTransaction: Transaction?
    
    // This controls if the "add transaction" popup is open
    @State private var showingAddSheet = false
    
    // This controls if the "edit transaction" popup is open
    @State private var showingEditSheet = false
    
    // This calculates how much money we have (income - expenses)
    var balance: Double {
        transactions.reduce(0) { total, transaction in
            total + (transaction.isIncome ? transaction.amount : -transaction.amount)
        }
    }
    
    var body: some View {
        // This creates the split screen layout (sidebar + detail)
        NavigationSplitView {
            // LEFT SIDE: List of transactions
            List(selection: $selectedTransaction) {
                // Balance section
                Section(NSLocalizedString("balance", comment: "Balance section")) {
                    Text("$\(balance, specifier: "%.2f")")
                        .font(.title)
                        .foregroundColor(balance >= 0 ? .green : .red)
                }
                
                // Transactions section
                Section(NSLocalizedString("transactions", comment: "Transactions section")) {
                    if transactions.isEmpty {
                        // Message when there are no transactions
                        Text("No transactions yet. Tap + to add one.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding()
                    } else {
                        // Show each transaction in a row
                        ForEach(transactions) { transaction in
                            NavigationLink(value: transaction) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(transaction.title)
                                            .font(.headline)
                                        Text(transaction.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("$\(transaction.amount, specifier: "%.2f")")
                                        .foregroundColor(transaction.isIncome ? .green : .red)
                                }
                            }
                        }
                        // Swipe left to delete
                        .onDelete(perform: deleteTransaction)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("finance_tracker_title", comment: "App title"))
            .toolbar {
                // Plus button to add new transaction
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        } detail: {
            // RIGHT SIDE: Transaction details
            if let transaction = selectedTransaction {
                DetailView(transaction: transaction, onEdit: {
                    showingEditSheet = true
                })
            } else {
                Text("Select a transaction")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        // Show "Add Transaction" popup
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView(transactions: $transactions)
        }
        // Show "Edit Transaction" popup
        .sheet(isPresented: $showingEditSheet) {
            if let transaction = selectedTransaction {
                EditTransactionView(transactions: $transactions, transaction: transaction)
            }
        }
    }
    
    // Delete a transaction when we swipe left
    func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        selectedTransaction = nil
    }
}

// Shows the details of one transaction
struct DetailView: View {
    let transaction: Transaction
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Big icon (arrow down = income, arrow up = expense)
            Image(systemName: transaction.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(transaction.isIncome ? .green : .red)
            
            // Title
            Text(transaction.title)
                .font(.title)
            
            // Amount
            Text("$\(transaction.amount, specifier: "%.2f")")
                .font(.largeTitle)
                .foregroundColor(transaction.isIncome ? .green : .red)
            
            // Date
            Text(transaction.date, style: .date)
                .font(.headline)
                .foregroundColor(.gray)
            
            // Type badge (Income or Expense)
            Text(transaction.isIncome ? NSLocalizedString("income", comment: "Income type") : NSLocalizedString("expense", comment: "Expense type"))
                .font(.subheadline)
                .padding(8)
                .background(transaction.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .cornerRadius(8)
            
            // Edit button
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding()
    }
}

// Form to add a new transaction
struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transactions: [Transaction]
    
    @State private var title = ""
    @State private var amount = ""
    @State private var isIncome = false
    @State private var date = Date()
    @State private var showError = false  // Shows error message if amount is invalid
    
    var body: some View {
        NavigationStack {
            Form {
                // Type in the name
                TextField(NSLocalizedString("title", comment: "Title field"), text: $title)
                
                // Type in the amount
                TextField(NSLocalizedString("amount", comment: "Amount field"), text: $amount)
                    .keyboardType(.decimalPad)
                
                // Pick a date
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                // Switch to choose Income or Expense
                Toggle(NSLocalizedString("income", comment: "Income toggle"), isOn: $isIncome)
                
                // Show error message if amount is not a valid number
                if showError {
                    Text("Please enter a valid number for amount")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .navigationTitle(NSLocalizedString("add_transaction", comment: "Add transaction title"))
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                }
                // Save button
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save", comment: "Save button")) {
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
                    // Disable Save button if title or amount is empty
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

// Form to edit an existing transaction
struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transactions: [Transaction]
    let transaction: Transaction
    
    @State private var title: String
    @State private var amount: String
    @State private var isIncome: Bool
    @State private var date: Date
    @State private var showError = false  // Shows error message if amount is invalid
    
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
            Form {
                // Change the name
                TextField(NSLocalizedString("title", comment: "Title field"), text: $title)
                
                // Change the amount
                TextField(NSLocalizedString("amount", comment: "Amount field"), text: $amount)
                    .keyboardType(.decimalPad)
                
                // Change the date
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                // Change Income/Expense
                Toggle(NSLocalizedString("income", comment: "Income toggle"), isOn: $isIncome)
                
                // Show error message if amount is not a valid number
                if showError {
                    Text("Please enter a valid number for amount")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Transaction")
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                }
                // Save button
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("save", comment: "Save button")) {
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
                    // Disable Save button if title or amount is empty
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
