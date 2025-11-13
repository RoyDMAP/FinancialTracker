//
//  ExpenseChartView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

struct ExpenseChartView: View {
    let transactions: [Transaction]
    @Environment(\.locale) var locale
    
    var expenseTransactions: [Transaction] {
        transactions.filter { !$0.isIncome }
    }
    
    var totalExpenses: Double {
        expenseTransactions.reduce(0) { $0 + $1.amountUSD }
    }
    
    var body: some View {
        let theme = AppTheme.current
        
        return ZStack {
            ThemedBackground(theme: theme)
            
            ScrollView {
                VStack(spacing: 20) {
                    if expenseTransactions.isEmpty {
                        emptyStateView
                    } else {
                        totalExpensesCard(theme: theme)
                        expensesList(theme: theme)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Expense Chart")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("No expenses to show")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Add some expense transactions!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private func totalExpensesCard(theme: AppTheme) -> some View {
        VStack(spacing: 10) {
            Text("Total Expenses")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Convert total to local currency
            let localTotal = CurrencyConverter.shared.convertFromUSD(totalExpenses)
            Text(CurrencyConverter.shared.format(localTotal))
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(theme.expenseColor)
                .id(locale)  // Force refresh on locale change
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(theme.cardBackground)
                .shadow(color: theme.expenseColor.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
    
    private func expensesList(theme: AppTheme) -> some View {
        VStack(spacing: 15) {
            ForEach(expenseTransactions.sorted(by: { $0.amountUSD > $1.amountUSD })) { transaction in
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(transaction.title)
                            .font(.headline)
                        Text(transaction.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(transaction.formattedAmount)
                            .font(.headline)
                            .foregroundColor(theme.expenseColor)
                        
                        let percentage = (transaction.amountUSD / totalExpenses) * 100 
                        Text("\(String(format: "%.1f", percentage))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(theme.cardBackground)
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseChartView(transactions: [
            Transaction(title: "Groceries", amount: 150, isIncome: false, date: Date()),
            Transaction(title: "Gas", amount: 50, isIncome: false, date: Date())
        ])
    }
}
