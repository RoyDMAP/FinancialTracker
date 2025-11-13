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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(transaction.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: transaction.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(transaction.isIncome ? .green : .red)
                        }
                        
                        Text(transaction.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("$\(transaction.amount, specifier: "%.2f")")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(transaction.isIncome ? .green : .red)
                        
                        Text(transaction.date, style: .date)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(transaction.isIncome ? "Income" : "Expense")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(transaction.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            )
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding()
                    
                    // Edit Button
                    Button(action: onEdit) {
                        HStack {
                            Image(systemName: "pencil")
                            Text(NSLocalizedString("edit_transaction", comment: "Edit Transaction"))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 30)
                    
                    // Delete Button
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text(NSLocalizedString("delete_transaction", comment: "Delete Transaction"))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15)
                        .shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 30)
                    
                    // Navigation Links Section
                    VStack(spacing: 15) {
                        // Link to Expense Chart
                        NavigationLink(destination: ExpenseChartView(transactions: transactions)) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.title2)
                                Text(NSLocalizedString("view_expense_chart", comment: "View Expense Chart"))
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.purple)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.purple.opacity(0.1))
                            )
                        }
                        
                        // Link to Monthly Report
                        NavigationLink(destination: MonthlyReportView(transactions: transactions)) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.title2)
                                Text(NSLocalizedString("view_monthly_report", comment: "View Monthly Report"))
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.indigo)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.indigo.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.vertical, 30)
            }
        }
    }
}

#Preview {
    DetailView(
        transaction: Transaction(
            title: "Groceries",
            amount: 150,
            isIncome: false,
            date: Date()
        ),
        transactions: [
            Transaction(title: "Groceries", amount: 150, isIncome: false, date: Date()),
            Transaction(title: "Gas", amount: 50, isIncome: false, date: Date())
        ],
        onEdit: {},
        onDelete: {}
    )
}
