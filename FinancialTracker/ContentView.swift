//
//  ContentView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/8/25.

import SwiftUI

struct ContentView: View {
    var currentUser: User?
    var onLogout: (() -> Void)?
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    @State private var transactions: [Transaction] = []
    @State private var selectedTransaction: Transaction?
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var showingDrawingSheet = false
    @State private var showingOptionsSheet = false
    @State private var selectedMonth: Date?
    @State private var showAllTransactions = true
    
    var availableMonths: [Date] {
        let calendar = Calendar.current
        let months = transactions.map { transaction in
            calendar.startOfMonth(for: transaction.date)
        }
        return Array(Set(months)).sorted(by: >)
    }
    
    var filteredTransactions: [Transaction] {
        guard !showAllTransactions, let month = selectedMonth else {
            return transactions
        }
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: month, toGranularity: .month)
        }
    }
    
    var balance: Double {
        filteredTransactions.reduce(0) { total, transaction in
            total + (transaction.isIncome ? transaction.amount : -transaction.amount)
        }
    }
    
    var body: some View {
        NavigationSplitView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                List(selection: $selectedTransaction) {
                    monthFilterSection
                    balanceSection
                    transactionsSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Finance Tracker")
            .toolbar {
                toolbarContent
        
            }
        } detail: {
            detailView
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView(transactions: $transactions, onSave: saveTransactions)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let transaction = selectedTransaction {
                EditTransactionView(transactions: $transactions, transaction: transaction, onSave: saveTransactions)
            }
        }
        .sheet(isPresented: $showingDrawingSheet) {
            DrawingCanvasView()
        }
        .confirmationDialog("Options", isPresented: $showingOptionsSheet) {
            optionsDialogContent
        }
        .onAppear {
            loadTransactions()
        }
    }
    
    // MARK: - View Components
    
    private var monthFilterSection: some View {
        Section {
            VStack(spacing: 12) {
                Toggle("Show All Months", isOn: $showAllTransactions)
                    .font(.subheadline)
                    .onChange(of: showAllTransactions) { oldValue, newValue in
                        if !newValue && !availableMonths.isEmpty {
                            selectedMonth = availableMonths.first
                        }
                    }
                
                if !showAllTransactions && !availableMonths.isEmpty {
                    Picker("Select Month", selection: Binding(
                        get: { selectedMonth ?? availableMonths.first ?? Date() },
                        set: { selectedMonth = $0 }
                    )) {
                        ForEach(availableMonths, id: \.self) { month in
                            Text(month.formatted(.dateTime.month(.wide).year()))
                                .tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }
    
    private var balanceSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(showAllTransactions ? "Total Balance" : "Monthly Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("$\(balance, specifier: "%.2f")")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(balance >= 0 ? .green : .red)
                }
                Spacer()
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(balance >= 0 ? .green : .red)
                    .opacity(0.3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(balance >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            )
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
    
    private var transactionsSection: some View {
        Section(showAllTransactions ? "All Transactions" : "Transactions This Month") {
            if filteredTransactions.isEmpty {
                emptyTransactionsView
            } else {
                transactionsList
            }
        }
    }
    
    private var emptyTransactionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text(showAllTransactions ? "No transactions yet" : "No transactions this month")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap + to add one")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
    }
    
    private var transactionsList: some View {
        ForEach(filteredTransactions.sorted(by: { $0.date > $1.date })) { transaction in
            NavigationLink(value: transaction) {
                TransactionRow(transaction: transaction)
            }
        }
        .onDelete(perform: deleteTransaction)
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                showingOptionsSheet = true
            }) {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
        }
    }
    
    private var detailView: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if let transaction = selectedTransaction {
                DetailView(
                    transaction: transaction,
                    transactions: transactions,
                    onEdit: { showingEditSheet = true }
                )
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("Select a transaction")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Tap any transaction to view details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var optionsDialogContent: some View {
        if let user = currentUser {
            Button("\(user.emoji) \(user.name)") { }
                .disabled(true)
        }
        
        Button("Drawing Notes") {
            showingDrawingSheet = true
        }
        
        Button(isDarkMode ? "☀️ Light Mode" : "🌙 Dark Mode") {
            isDarkMode.toggle()
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            
            print("🌙 Dark mode: \(isDarkMode)")
            
            Task { @MainActor in
                for scene in UIApplication.shared.connectedScenes {
                    if let windowScene = scene as? UIWindowScene {
                        for window in windowScene.windows {
                            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                            }
                        }
                    }
                }
            }
        }
        
        if onLogout != nil {
            Button("Switch User", role: .destructive) {
                onLogout?()
            }
        }
        
        Button("Cancel", role: .cancel) { }
    }
    
    
    // MARK: - Functions
    
    func deleteTransaction(at offsets: IndexSet) {
        let transactionsToDelete = offsets.map { filteredTransactions[$0] }
        transactions.removeAll { transaction in
            transactionsToDelete.contains(where: { $0.id == transaction.id })
        }
        selectedTransaction = nil
        saveTransactions()
    }
    
    func saveTransactions() {
        let key = currentUser != nil ? "SavedTransactions_\(currentUser!.id.uuidString)" : "SavedTransactions"
        
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: key)
            print("✅ Saved \(transactions.count) transactions")
        }
        ExternalDisplayManager.shared.updateDisplay(transactions: transactions, balance: balance)
    }
    
    func loadTransactions() {
        let key = currentUser != nil ? "SavedTransactions_\(currentUser!.id.uuidString)" : "SavedTransactions"
        
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: savedData) {
            transactions = decoded
            print("✅ Loaded \(transactions.count) transactions")
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(transaction.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundColor(transaction.isIncome ? .green : .red)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("$\(transaction.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(transaction.isIncome ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
