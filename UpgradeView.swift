//
//  UpgradeView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/24/25.
//

import SwiftUI

struct UpgradeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var storeManager: StoreManager
    @State private var isPurchasing = false
    
    var body: some View {
        let theme = AppTheme.current
        
        return NavigationStack {
            ZStack {
                ThemedBackground(theme: theme)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.yellow)
                            
                            Text("Upgrade to Pro")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Unlock unlimited features")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                        
                        // Features List
                        VStack(alignment: .leading, spacing: 20) {
                            FeatureRow(icon: "person.3.fill", title: "Unlimited Users", description: "Create as many user profiles as you need")
                            FeatureRow(icon: "list.bullet.rectangle.fill", title: "Unlimited Transactions", description: "Track all your income and expenses")
                            FeatureRow(icon: "chart.pie.fill", title: "Advanced Charts", description: "Detailed expense breakdowns and trends")
                            FeatureRow(icon: "arrow.down.doc.fill", title: "Export Data", description: "Export to PDF and CSV formats")
                            FeatureRow(icon: "icloud.fill", title: "Cloud Backup", description: "Secure iCloud sync (coming soon)")
                            FeatureRow(icon: "sparkles", title: "Future Updates", description: "All premium features we add in the future")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.cardBackground)
                        )
                        .padding(.horizontal)
                        
                        // Price
                        VStack(spacing: 10) {
                            Text("$4.99")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(theme.primaryColor)
                            
                            Text("One-time purchase")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("No subscription required!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        .padding()
                        
                        // Purchase Button
                        Button(action: {
                            purchasePro()
                        }) {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Upgrade Now")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(theme.primaryColor)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .disabled(isPurchasing)
                        
                        // Restore Purchases Button
                        Button(action: {
                            storeManager.restorePurchases()
                        }) {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(theme.secondaryColor)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func purchasePro() {
        isPurchasing = true
        
        // Simulate purchase process
        storeManager.buyProVersion()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPurchasing = false
            dismiss()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)
        }
    }
}

#Preview {
    UpgradeView(storeManager: StoreManager())
}
