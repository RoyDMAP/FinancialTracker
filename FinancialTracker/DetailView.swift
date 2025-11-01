//
//  DetailView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.


import SwiftUI

struct DetailView: View {
    let transaction: Transaction
    let onEdit: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    // Big icon with circular background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: transaction.isIncome
                                        ? [Color.green.opacity(0.3), Color.green.opacity(0.1)]
                                        : [Color.red.opacity(0.3), Color.red.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
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
                
                // Edit button with gradient
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Transaction")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 30)
            }
            .padding(.vertical, 30)
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
        onEdit: {}
    )
}
