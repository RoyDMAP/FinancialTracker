//
//  MonthlyReportView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

struct MonthlyReportView: View {
    let transactions: [Transaction]
    @Environment(\.locale) var locale
    
    var monthlyData: [(month: Date, income: Double, expenses: Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfMonth(for: transaction.date)
        }
        
        return grouped.map { month, transactions in
            let income = transactions
                .filter { $0.isIncome }
                .reduce(0) { $0 + $1.amountUSD }
            
            let expenses = transactions
                .filter { !$0.isIncome }
                .reduce(0) { $0 + $1.amountUSD }
            
            return (month: month, income: income, expenses: expenses)
        }
        .sorted { $0.month > $1.month }
    }
    
    var totalIncome: Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amountUSD }
    }
    
    var totalExpenses: Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amountUSD }  
    }
    
    var body: some View {
        let theme = AppTheme.current
        
        return ZStack {
            ThemedBackground(theme: theme)
            
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards(theme: theme)
                    monthlyBreakdown(theme: theme)
                }
                .padding()
            }
        }
        .navigationTitle("Monthly Reports")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func summaryCards(theme: AppTheme) -> some View {
        HStack(spacing: 15) {
            SummaryCard(
                title: "Total Income",
                amount: CurrencyConverter.shared.convertFromUSD(totalIncome),
                color: theme.incomeColor,
                icon: "arrow.down.circle.fill"
            )
            
            SummaryCard(
                title: "Total Expenses",
                amount: CurrencyConverter.shared.convertFromUSD(totalExpenses),
                color: theme.expenseColor,
                icon: "arrow.up.circle.fill"
            )
            
            SummaryCard(
                title: "Net",
                amount: CurrencyConverter.shared.convertFromUSD(totalIncome - totalExpenses),
                color: (totalIncome - totalExpenses) >= 0 ? theme.incomeColor : theme.expenseColor,
                icon: "equal.circle.fill"
            )
        }
        .id(locale)
    }
    
    private func monthlyBreakdown(theme: AppTheme) -> some View {
        VStack(spacing: 15) {
            Text("Monthly Breakdown")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            if monthlyData.isEmpty {
                emptyStateView
            } else {
                ForEach(monthlyData, id: \.month) { data in
                    MonthCard(
                        month: data.month,
                        income: data.income,
                        expenses: data.expenses,
                        theme: theme
                    )
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("No monthly data available")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 50)
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    @Environment(\.locale) var locale
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(CurrencyConverter.shared.format(amount))
                .font(.headline)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
        )
    }
}

struct MonthCard: View {
    let month: Date
    let income: Double
    let expenses: Double
    let theme: AppTheme
    @Environment(\.locale) var locale
    
    var netAmount: Double {
        income - expenses
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(theme.incomeColor)
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(CurrencyConverter.shared.format(CurrencyConverter.shared.convertFromUSD(income)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.incomeColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    HStack {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(theme.expenseColor)
                    }
                    Text(CurrencyConverter.shared.format(CurrencyConverter.shared.convertFromUSD(expenses)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.expenseColor)
                }
            }
            
            Divider()
            
            HStack {
                Text("Net")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(CurrencyConverter.shared.format(CurrencyConverter.shared.convertFromUSD(netAmount)))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(netAmount >= 0 ? theme.incomeColor : theme.expenseColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(theme.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        MonthlyReportView(transactions: [
            Transaction(title: "Salary", amount: 3000, isIncome: true, date: Date()),
            Transaction(title: "Groceries", amount: 150, isIncome: false, date: Date()),
            Transaction(title: "Gas", amount: 50, isIncome: false, date: Date())
        ])
    }
}
