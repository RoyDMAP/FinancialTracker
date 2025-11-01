//
//  ContentView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.


import SwiftUI

struct ContentView: View {
    // List of all our transactions (starts empty)
    @State private var transactions: [Transaction] = []
    
    // Which transaction did we tap on?
    @State private var selectedTransaction: Transaction?
    
    // Is the "Add Transaction" popup open?
    @State private var showingAddSheet = false
    
    // Is the "Edit Transaction" popup open?
    @State private var showingEditSheet = false
    
    // Is the "Chart" popup open?
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
            // LEFT SIDE with gradient background
            ZStack {
                // Cool gradient background for sidebar
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                List(selection: $selectedTransaction) {
                    // Balance section with card style
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Balance")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("$\(balance, specifier: "%.2f")")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(balance >= 0 ? .green : .red)
                            }
                            Spacer()
                            // Money icon
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(balance >= 0 ? .green : .red)
                                .opacity(0.3)
                        }
                        .padding()
                        .background(
                            // Gradient card background
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
                    
                    // Transactions section
                    Section("Transactions") {
                        if transactions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No transactions yet")
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
                            ForEach(transactions) { transaction in
                                NavigationLink(value: transaction) {
                                    HStack {
                                        // Circle icon for transaction type
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
                .scrollContentBackground(.hidden)  // Hide default list background
            }
            .navigationTitle("Finance Tracker")
            .toolbar {
                // Chart button (top left)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingChartSheet = true }) {
                        Label("Chart", systemImage: "chart.bar.fill")
                    }
                }
                
                // Add button (top right)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        } detail: {
            // RIGHT SIDE with gradient background
            ZStack {
                // Cool gradient background for detail view
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if let transaction = selectedTransaction {
                    DetailView(transaction: transaction, onEdit: {
                        showingEditSheet = true
                    })
                } else {
                    // Placeholder when nothing is selected
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
        // Show "Chart" popup
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

#Preview {
    ContentView()
}
