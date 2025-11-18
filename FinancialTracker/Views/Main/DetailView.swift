//
//  DetailView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.

import SwiftUI

struct DetailView: View {
    let transaction: Transaction
    let transactions: [Transaction]
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.locale) var locale
    
    var body: some View {
        let theme = AppTheme.current
        
        return NavigationStack {
            ZStack {
                ThemedBackground(theme: theme)
                
                ScrollView {
                    VStack(spacing: 30) {
                        transactionCard(theme: theme)
                        
                        if CurrencyConverter.shared.currentCurrencyCode != "USD" {
                            currencyInfoCard(theme: theme)
                        }
                        
                        actionButtons(theme: theme)
                        navigationLinks(theme: theme)
                    }
                    .padding(.vertical, 30)
                }
            }
        }
    }
    
    private func transactionCard(theme: AppTheme) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(transaction.isIncome ? theme.incomeColor.opacity(0.2) : theme.expenseColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: transaction.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(transaction.isIncome ? theme.incomeColor : theme.expenseColor)
            }
            
            Text(transaction.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(transaction.formattedAmount)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(transaction.isIncome ? theme.incomeColor : theme.expenseColor)
                .id(locale)
            
            if CurrencyConverter.shared.currentCurrencyCode != "USD" {
                Text("($\(String(format: "%.2f", transaction.amountUSD)) USD)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(transaction.date, style: .date)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(transaction.isIncome ? NSLocalizedString("income", comment: "Income") : NSLocalizedString("expense", comment: "Expense"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(transaction.isIncome ? theme.incomeColor.opacity(0.2) : theme.expenseColor.opacity(0.2))
                )
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
                .shadow(color: theme.primaryColor.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
    
    private func currencyInfoCard(theme: AppTheme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(theme.primaryColor)
                Text("Currency Conversion")
                    .font(.headline)
                    .foregroundColor(theme.primaryColor)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Original (USD):")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.2f", transaction.amountUSD))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Current (\(CurrencyConverter.shared.currentCurrencyCode)):")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(transaction.formattedAmount)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.primaryColor)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(CurrencyConverter.shared.getExchangeRateInfo())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(theme.primaryColor.opacity(0.1))
        )
        .padding(.horizontal, 30)
    }
    
    private func actionButtons(theme: AppTheme) -> some View {
        VStack(spacing: 15) {
            Button(action: onEdit) {
                CulturalIconLabel(
                    icon: "pencil",
                    text: NSLocalizedString("edit_transaction", comment: "Edit Transaction")
                )
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.primaryColor)
                .cornerRadius(15)
                .shadow(color: theme.primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 30)
            .accessibilityIdentifier("editTransactionButton")
            
            Button(role: .destructive) {
                onDelete()
                dismiss()
            } label: {
                CulturalIconLabel(
                    icon: "trash",
                    text: NSLocalizedString("delete_transaction", comment: "Delete Transaction")
                )
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.expenseColor)
                .cornerRadius(15)
                .shadow(color: theme.expenseColor.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 30)
            .accessibilityIdentifier("deleteTransactionButton")
        }
    }
    
    private func navigationLinks(theme: AppTheme) -> some View {
        VStack(spacing: 15) {
            NavigationLink(destination: ExpenseChartView(transactions: transactions)) {
                HStack {
                    CulturalIconLabel(
                        icon: "chart.bar.fill",
                        text: NSLocalizedString("view_expense_chart", comment: "View Expense Chart")
                    )
                    .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .foregroundColor(theme.secondaryColor)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(theme.secondaryColor.opacity(0.1))
                )
            }
            
            NavigationLink(destination: MonthlyReportView(transactions: transactions)) {
                HStack {
                    CulturalIconLabel(
                        icon: "calendar",
                        text: NSLocalizedString("view_monthly_report", comment: "View Monthly Report")
                    )
                    .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .foregroundColor(theme.accentColor)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(theme.accentColor.opacity(0.1))
                )
            }
        }
        .padding(.horizontal, 30)
    }
}

