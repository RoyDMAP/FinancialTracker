//
//  ContentView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.

import SwiftUI

struct ContentView: View {
    @State private var transactions: [Transaction] = []
    @State private var selectedTransaction: Transaction?
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
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
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                List(selection: $selectedTransaction) {
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
                    .listRowBackground(Color.white.opacity(0.8))
                    
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
                            LinearGradient(
                                colors: balance >= 0
                                    ? [Color.green.opacity(0.1), Color.green.opacity(0.05)]
                                    : [Color.red.opacity(0.1), Color.red.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(15)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    
                    Section(showAllTransactions ? "All Transactions" : "Transactions This Month") {
                        if filteredTransactions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text(showAllTransactions ? "No transactions yet" : "No transactions this month")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("Tap + to add one")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(filteredTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                                NavigationLink(value: transaction) {
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
                            .onDelete(perform: deleteTransaction)
                            .listRowBackground(Color.white.opacity(0.8))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Finance Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        } detail: {
            ZStack {
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
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
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Select a transaction")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Tap any transaction to view details")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView(transactions: $transactions, onSave: saveTransactions)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let transaction = selectedTransaction {
                EditTransactionView(transactions: $transactions, transaction: transaction, onSave: saveTransactions)
            }
        }
        .onAppear {
            loadTransactions()
        }
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        let transactionsToDelete = offsets.map { filteredTransactions[$0] }
        transactions.removeAll { transaction in
            transactionsToDelete.contains(where: { $0.id == transaction.id })
        }
        selectedTransaction = nil
        saveTransactions()
    }
    
    func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: "SavedTransactions")
            print("✅ Saved \(transactions.count) transactions!")
        }
        ExternalDisplayManager.shared.updateDisplay(transactions: transactions, balance: balance)
    }
    
    func loadTransactions() {
        if let savedData = UserDefaults.standard.data(forKey: "SavedTransactions"),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: savedData) {
            transactions = decoded
            print("✅ Loaded \(transactions.count) transactions!")
        } else {
            print("ℹ️ No saved transactions found - starting fresh")
        }
    }
}

#Preview {
    ContentView()
}
