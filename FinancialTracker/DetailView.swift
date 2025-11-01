//
//  DetailView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.


import SwiftUI

// Shows the details of one transaction
struct DetailView: View {
    let transaction: Transaction  // The transaction to show
    let onEdit: () -> Void  // What happens when Edit button is tapped
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Card that shows all transaction info
                VStack(spacing: 20) {
                    // Big icon with circular gradient background
                    ZStack {
                        // Gradient circle background
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: transaction.isIncome
                                        ? [Color.green.opacity(0.3), Color.green.opacity(0.1)]  // Green gradient for income
                                        : [Color.red.opacity(0.3), Color.red.opacity(0.1)],     // Red gradient for expense
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        // Arrow icon (down = income, up = expense)
                        Image(systemName: transaction.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(transaction.isIncome ? .green : .red)
                    }
                    
                    // Transaction title (e.g., "Groceries")
                    Text(transaction.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Transaction amount (big and bold)
                    Text("$\(transaction.amount, specifier: "%.2f")")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(transaction.isIncome ? .green : .red)
                    
                    // Transaction date
                    Text(transaction.date, style: .date)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Type badge (Income or Expense)
                    Text(transaction.isIncome ? "Income" : "Expense")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()  // Pill-shaped background
                                .fill(transaction.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        )
                }
                .padding(30)
                .background(
                    // White card with rounded corners and shadow
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding()
                
                // Edit button with blue gradient
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")  // Pencil icon
                        Text("Edit Transaction")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        // Blue gradient background
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)  // Blue glow effect
                }
                .padding(.horizontal, 30)
            }
            .padding(.vertical, 30)
        }
    }
}

// Preview for testing in Xcode
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
