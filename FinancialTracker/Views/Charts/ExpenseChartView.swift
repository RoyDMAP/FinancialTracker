//
//  ExpenseChartView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI
import Charts

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
                        pieChartView(theme: theme)
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
            
            let localTotal = CurrencyConverter.shared.convertFromUSD(totalExpenses)
            Text(CurrencyConverter.shared.format(localTotal))
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(theme.expenseColor)
                .id(locale)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(theme.cardBackground)
                .shadow(color: theme.expenseColor.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
    
    private func pieChartView(theme: AppTheme) -> some View {
        VStack(spacing: 15) {
            Text("Expense Breakdown")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if #available(iOS 16.0, *) {
                Chart(expenseTransactions.sorted(by: { $0.amountUSD > $1.amountUSD })) { transaction in
                    SectorMark(
                        angle: .value("Amount", transaction.amountUSD),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", transaction.title))
                    .cornerRadius(5)
                }
                .frame(height: 300)
                .chartLegend(position: .bottom, alignment: .center, spacing: 10)
            } else {
                // Fallback for iOS 15 - Simple bar representation
                VStack(spacing: 10) {
                    ForEach(expenseTransactions.sorted(by: { $0.amountUSD > $1.amountUSD })) { transaction in
                        HStack {
                            Text(transaction.title)
                                .font(.caption)
                                .frame(width: 100, alignment: .leading)
                            
                            GeometryReader { geometry in
                                let percentage = transaction.amountUSD / totalExpenses
                                let width = geometry.size.width * percentage
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(theme.expenseColor)
                                    .frame(width: width, height: 20)
                            }
                            .frame(height: 20)
                            
                            Text("\(Int(transaction.amountUSD / totalExpenses * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(theme.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func expensesList(theme: AppTheme) -> some View {
        VStack(spacing: 15) {
            Text("Detailed List")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
            Transaction(title: "Gas", amount: 50, isIncome: false, date: Date()),
            Transaction(title: "Rent", amount: 1200, isIncome: false, date: Date()),
            Transaction(title: "Utilities", amount: 100, isIncome: false, date: Date())
        ])
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
