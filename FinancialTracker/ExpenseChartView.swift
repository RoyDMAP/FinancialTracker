//
//  ExpenseChartView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI
import Charts

struct ExpenseChartView: View {
    @Environment(\.dismiss) var dismiss
    let transactions: [Transaction]
    
    // Group expenses by title and sum them
    var expensesByTitle: [ExpenseData] {
        let expenses = transactions.filter { !$0.isIncome }
        let grouped = Dictionary(grouping: expenses) { $0.title }
        return grouped.map { title, transactionList in
            let total = transactionList.reduce(0) { $0 + $1.amount }
            return ExpenseData(title: title, total: total)
        }
        .sorted { $0.total > $1.total }
    }
    
    var totalExpenses: Double {
        expensesByTitle.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        if expensesByTitle.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "chart.bar")
                                    .font(.system(size: 70))
                                    .foregroundColor(.purple.opacity(0.3))
                                Text("No expenses to show yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                Text("Add some expense transactions to see your spending habits!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 80)
                        } else {
                            
                            VStack(spacing: 12) {
                                Text("Total Expenses")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("$\(totalExpenses, specifier: "%.2f")")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(25)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.red.opacity(0.1), Color.orange.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Spending by Category")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                Chart(expensesByTitle) { expense in
                                    BarMark(
                                        x: .value("Amount", expense.total),
                                        y: .value("Category", expense.title)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.red, Color.orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .annotation(position: .trailing) {
                                        Text("$\(expense.total, specifier: "%.0f")")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.red)
                                    }
                                }
                                .frame(height: CGFloat(expensesByTitle.count * 50))
                                .padding()
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Breakdown")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                ForEach(expensesByTitle) { expense in
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.red.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "cart.fill")
                                                .foregroundColor(.red)
                                        }
                                        
                                        Text(expense.title)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("$\(expense.total, specifier: "%.2f")")
                                                .font(.headline)
                                                .foregroundColor(.red)
                                            
                                            Text("\(expense.percentage(of: totalExpenses), specifier: "%.1f")%")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.9))
                                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Expense Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExpenseData: Identifiable {
    let id = UUID()
    let title: String
    let total: Double
    
    func percentage(of total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (self.total / total) * 100
    }
}

#Preview {
    ExpenseChartView(transactions: [
        Transaction(title: "Groceries", amount: 150, isIncome: false, date: Date()),
        Transaction(title: "Gas", amount: 50, isIncome: false, date: Date())
    ])
}
