//
//  ContentView.swift
//  FinancialTracker
//

import SwiftUI

struct ContentView: View {
    var currentUser: User?
    @ObservedObject var storeManager: StoreManager  // ← ADD THIS
    var onLogout: (() -> Void)?
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.locale) var locale
    
    @State private var transactions: [Transaction] = []
    @State private var selectedTransaction: Transaction?
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var showingDrawingSheet = false
    @State private var showingOptionsSheet = false
    @State private var showingLocaleInfo = false
    @State private var selectedMonth: Date?
    @State private var showAllTransactions = true
    @State private var showingUpgradeAlert = false  // ← ADD THIS
    @State private var showingUpgradeSheet = false  // ← ADD THIS
    
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
            total + (transaction.isIncome ? transaction.amountUSD : -transaction.amountUSD)
        }
    }
    
    var body: some View {
        let theme = AppTheme.current
        
        return NavigationSplitView {
            ZStack {
                ThemedBackground(theme: theme)
                
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
                    .listRowBackground(theme.cardBackground)
                    
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(showAllTransactions ? "Total Balance" : "Monthly Balance")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                let localBalance = CurrencyConverter.shared.convertFromUSD(balance)
                                Text(CurrencyConverter.shared.format(localBalance))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(balance >= 0 ? theme.incomeColor : theme.expenseColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .id(locale)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(balance >= 0 ? theme.incomeColor : theme.expenseColor)
                                .opacity(0.3)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(balance >= 0 ? theme.incomeColor.opacity(0.1) : theme.expenseColor.opacity(0.1))
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    
                    // Show trial status if not Pro
                    if !storeManager.isPro {
                        Section {
                            VStack(spacing: 10) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Free Trial")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                Text("\(transactions.count)/5 transactions used")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    showingUpgradeSheet = true
                                }) {
                                    Text("Upgrade to Pro")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(theme.primaryColor)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                        }
                        .listRowBackground(theme.cardBackground)
                    }
                    
                    Section(showAllTransactions ? "All Transactions" : "Transactions This Month") {
                        if filteredTransactions.isEmpty {
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
                        } else {
                            ForEach(filteredTransactions.sorted(by: { $0.date > $1.date })) { transaction in
                                NavigationLink(value: transaction) {
                                    TransactionRow(transaction: transaction, theme: theme)
                                        .id("\(transaction.id)-\(locale)")
                                }
                            }
                            .onDelete(perform: deleteTransaction)
                            .listRowBackground(theme.cardBackground)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Finance Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingOptionsSheet = true
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(theme.primaryColor)
                    }
                    .accessibilityIdentifier("optionsButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        // Check if user can add more transactions
                        if storeManager.canAddTransaction(currentTransactionCount: transactions.count) {
                            showingAddSheet = true
                        } else {
                            showingUpgradeAlert = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.primaryColor)
                    }
                    .accessibilityIdentifier("addTransactionButton")
                }
            }
        } detail: {
            ZStack {
                ThemedBackground(theme: theme)
                
                if let transaction = selectedTransaction {
                    DetailView(
                        transaction: transaction,
                        transactions: transactions,
                        onEdit: { showingEditSheet = true },
                        onDelete: {
                            transactions.removeAll { $0.id == transaction.id }
                            selectedTransaction = nil
                            saveTransactions()
                        }
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
        .sheet(isPresented: $showingLocaleInfo) {
            LocaleInfoView()
        }
        .sheet(isPresented: $showingUpgradeSheet) {
            UpgradeView(storeManager: storeManager)
        }
        .alert("Upgrade to Pro", isPresented: $showingUpgradeAlert) {
            Button("Upgrade - $4.99") {
                showingUpgradeSheet = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(storeManager.getTransactionLimitMessage())
        }
        .confirmationDialog("Options", isPresented: $showingOptionsSheet) {
            if let user = currentUser {
                Button(action: {}) {
                    HStack(spacing: 8) {
                        if let photoData = user.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        } else {
                            Text(user.emoji)
                                .font(.title3)
                        }
                        Text(user.name)
                    }
                }
                .disabled(true)
            }
            
            Button(NSLocalizedString("drawing_notes", comment: "Drawing Notes")) {
                showingDrawingSheet = true
            }
            
            Button(NSLocalizedString("locale_info", comment: "Locale Information")) {
                showingLocaleInfo = true
            }
            
            Button(isDarkMode ? "☀️ Light Mode" : "🌙 Dark Mode") {
                isDarkMode.toggle()
                UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
                
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
            
            if !storeManager.isPro {
                Button("Upgrade to Pro - $4.99") {
                    showingUpgradeSheet = true
                }
            }
            
            if onLogout != nil {
                Button(NSLocalizedString("switch_user", comment: "Switch User"), role: .destructive) {
                    onLogout?()
                }
            }
            
            Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) { }
        }
        .onAppear {
            loadTransactions()
        }
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredTransactions[$0].id }
        transactions.removeAll { transaction in
            idsToDelete.contains(transaction.id)
        }
        if let selected = selectedTransaction, idsToDelete.contains(selected.id) {
            selectedTransaction = nil
        }
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

// TransactionRow remains the same
struct TransactionRow: View {
    let transaction: Transaction
    let theme: AppTheme
    @Environment(\.locale) var locale
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(transaction.isIncome ? theme.incomeColor.opacity(0.2) : theme.expenseColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundColor(transaction.isIncome ? theme.incomeColor : theme.expenseColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.formattedAmount)
                .font(.headline)
                .foregroundColor(transaction.isIncome ? theme.incomeColor : theme.expenseColor)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView(storeManager: StoreManager())
}
