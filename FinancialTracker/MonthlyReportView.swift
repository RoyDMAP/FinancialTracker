//
//  MonthlyReportView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI
import Charts

struct MonthlyReportView: View {
    @Environment(\.dismiss) var dismiss
    let transactions: [Transaction]
    
    @State private var selectedMonth: Date = Date()
    
    var availableMonths: [Date] {
        let calendar = Calendar.current
        let months = transactions.map { transaction in
            calendar.startOfMonth(for: transaction.date)
        }
        return Array(Set(months)).sorted(by: >)
    }
    
    var monthTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedMonth, toGranularity: .month)
        }
    }
    
    var monthIncome: Double {
        monthTransactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var monthExpenses: Double {
        monthTransactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var monthBalance: Double {
        monthIncome - monthExpenses
    }
    
    var expensesByCategory: [ExpenseCategory] {
        let expenses = monthTransactions.filter { !$0.isIncome }
        let grouped = Dictionary(grouping: expenses) { $0.title }
        return grouped.map { title, list in
            let total = list.reduce(0) { $0 + $1.amount }
            return ExpenseCategory(name: title, amount: total)
        }.sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.indigo.opacity(0.05)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        if !availableMonths.isEmpty {
                            VStack(spacing: 10) {
                                Text("Select Month")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Picker("Month", selection: $selectedMonth) {
                                    ForEach(availableMonths, id: \.self) { month in
                                        Text(month.formatted(.dateTime.month(.wide).year()))
                                            .tag(month)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 150)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                            )
                            .padding(.horizontal)
                        }
                        
                        if monthTransactions.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 70))
                                    .foregroundColor(.indigo.opacity(0.3))
                                Text("No transactions this month")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 80)
                        } else {
                            VStack(spacing: 15) {
                                Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                VStack(spacing: 10) {
                                    Text("Net Balance")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("$\(monthBalance, specifier: "%.2f")")
                                        .font(.system(size: 42, weight: .bold))
                                        .foregroundColor(monthBalance >= 0 ? .green : .red)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(25)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(monthBalance >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                                )
                                
                                HStack(spacing: 15) {
                                    VStack(spacing: 10) {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.green)
                                        Text("Income")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("$\(monthIncome, specifier: "%.2f")")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.green.opacity(0.1))
                                    )
                                    
                                    VStack(spacing: 10) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.red)
                                        Text("Expenses")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("$\(monthExpenses, specifier: "%.2f")")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.red.opacity(0.1))
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            if !expensesByCategory.isEmpty {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Expense Breakdown")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                    
                                    Chart(expensesByCategory) { category in
                                        BarMark(
                                            x: .value("Amount", category.amount),
                                            y: .value("Category", category.name)
                                        )
                                        .foregroundStyle(Color.red)
                                        .annotation(position: .trailing) {
                                            Text("$\(category.amount, specifier: "%.0f")")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .frame(height: CGFloat(expensesByCategory.count * 50))
                                    .padding()
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                                )
                                .padding(.horizontal)
                            }
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("All Transactions (\(monthTransactions.count))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                ForEach(monthTransactions.sorted(by: { $0.date > $1.date })) { transaction in
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
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.9))
                                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Monthly Reports")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if !availableMonths.isEmpty {
                selectedMonth = availableMonths.first ?? Date()
            }
        }
    }
}

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}

#Preview {
    MonthlyReportView(transactions: [
        Transaction(title: "Salary", amount: 3000, isIncome: true, date: Date()),
        Transaction(title: "Groceries", amount: 150, isIncome: false, date: Date()),
        Transaction(title: "Gas", amount: 50, isIncome: false, date: Date())
    ])
}
