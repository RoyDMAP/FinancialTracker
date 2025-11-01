//
//  ContentView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.


import SwiftUI
import Charts  // This lets us make charts and graphs

struct ContentView: View {
    // List of all our transactions (starts empty)
    @State private var transactions: [Transaction] = []
    
    // Which transaction did we tap on?
    @State private var selectedTransaction: Transaction?
    
    // Is the "Add Transaction" popup open?
    @State private var showingAddSheet = false
    
    // Is the "Edit Transaction" popup open?
    @State private var showingEditSheet = false
    
    // NEW: Is the "Chart" popup open?
    @State private var showingChartSheet = false
    
    // Calculate total money (income minus expenses)
    var balance: Double {
        transactions.reduce(0) { total, transaction in
            total + (transaction.isIncome ? transaction.amount : -transaction.amount)
        }
    }
    
    var body: some View {
        // Split screen: sidebar on left, detail on right
        NavigationSplitView {
            // LEFT SIDE: Transaction list
            List(selection: $selectedTransaction) {
                // Balance section
                Section("Balance") {
                    Text("$\(balance, specifier: "%.2f")")
                        .font(.title)
                        .foregroundColor(balance >= 0 ? .green : .red)
                }
                
                // Transactions section
                Section("Transactions") {
                    if transactions.isEmpty {
                        Text("No transactions yet. Tap + to add one.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding()
                    } else {
                        // Show each transaction
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
                        .onDelete(perform: deleteTransaction)
                    }
                }
            }
            .navigationTitle("Finance Tracker")
            .toolbar {
                // NEW: Chart button (top left)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingChartSheet = true }) {
                        Label("Chart", systemImage: "chart.bar.fill")
                    }
                }
                
                // Add button (top right)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
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
        // NEW: Show "Chart" popup
        .sheet(isPresented: $showingChartSheet) {
            ExpenseChartView(transactions: transactions)
        }
    }
    
    // Delete transaction when we swipe left
    func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        selectedTransaction = nil
    }
}

struct DetailView: View {
    let transaction: Transaction
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Big icon
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
            
            // Type badge
            Text(transaction.isIncome ? "Income" : "Expense")
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

// NEW: Screen that shows a chart of your spending habits
struct ExpenseChartView: View {
    @Environment(\.dismiss) var dismiss
    let transactions: [Transaction]
    
    // Group expenses by name and add them up
    // Example: If you have 2 "Groceries" transactions ($100 and $50),
    // this combines them into one: Groceries = $150
    var expensesByTitle: [ExpenseData] {
        // Step 1: Only get expenses (skip income)
        let expenses = transactions.filter { !$0.isIncome }
        
        // Step 2: Group by title (put all "Groceries" together, all "Gas" together, etc.)
        let grouped = Dictionary(grouping: expenses) { $0.title }
        
        // Step 3: Add up the amounts for each group
        return grouped.map { title, transactionList in
            let total = transactionList.reduce(0) { $0 + $1.amount }
            return ExpenseData(title: title, total: total)
        }
        .sorted { $0.total > $1.total }  // Put biggest expense first
    }
    
    // Add up ALL expenses to get a total
    var totalExpenses: Double {
        expensesByTitle.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Check if we have any expenses
                    if expensesByTitle.isEmpty {
                        // No expenses yet - show message
                        VStack(spacing: 20) {
                            Image(systemName: "chart.bar")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No expenses to show yet")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Add some expense transactions to see your spending habits!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .padding(.top, 100)
                    } else {
                        // We have expenses - show the chart!
                        
                        // Total expenses at the top
                        VStack(spacing: 8) {
                            Text("Total Expenses")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("$\(totalExpenses, specifier: "%.2f")")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .padding(.top)
                        
                        // Bar chart showing each category
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending by Category")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            // The actual bar chart
                            Chart(expensesByTitle) { expense in
                                // Make a horizontal bar for each expense type
                                BarMark(
                                    x: .value("Amount", expense.total),  // How long the bar is
                                    y: .value("Category", expense.title) // Which row it's on
                                )
                                .foregroundStyle(.red)  // Red bars for expenses
                                .annotation(position: .trailing) {
                                    // Put the dollar amount at the end of each bar
                                    Text("$\(expense.total, specifier: "%.0f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(height: CGFloat(expensesByTitle.count * 50))  // Make chart taller if we have more categories
                            .padding()
                        }
                        
                        // Detailed list below the chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Breakdown")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            // Show each expense category in a box
                            ForEach(expensesByTitle) { expense in
                                HStack {
                                    // Category name (e.g., "Groceries")
                                    Text(expense.title)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        // How much spent
                                        Text("$\(expense.total, specifier: "%.2f")")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                        
                                        // What percent of total (e.g., "25%")
                                        Text("\(expense.percentage(of: totalExpenses), specifier: "%.1f")%")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))  // Light gray background
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Expense Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Done button to close the chart
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Helper: Holds data for one expense category
struct ExpenseData: Identifiable {
    let id = UUID()
    let title: String  // Name (e.g., "Groceries")
    let total: Double  // Total amount spent
    
    // Calculate what percent this is of all expenses
    // Example: If you spent $100 on groceries and $400 total, this returns 25
    func percentage(of total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (self.total / total) * 100
    }
}

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transactions: [Transaction]
    
    @State private var title = ""
    @State private var amount = ""
    @State private var isIncome = false
    @State private var date = Date()
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Toggle("Income", isOn: $isIncome)
                
                if showError {
                    Text("Please enter a valid number for amount")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .navigationTitle("Add Transaction")
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

struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transactions: [Transaction]
    let transaction: Transaction
    
    @State private var title: String
    @State private var amount: String
    @State private var isIncome: Bool
    @State private var date: Date
    @State private var showError = false
    
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
                TextField("Title", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Toggle("Income", isOn: $isIncome)
                
                if showError {
                    Text("Please enter a valid number for amount")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Transaction")
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
    ContentView()
}
