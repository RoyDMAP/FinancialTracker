//
//  CulturalButton.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/10/25.
//

import SwiftUI

struct CulturalButtonRow: View {
    let primaryTitle: String
    let primaryAction: () -> Void
    let secondaryTitle: String
    let secondaryAction: () -> Void
    let primaryRole: ButtonRole?
    
    @Environment(\.layoutDirection) var layoutDirection
    
    var body: some View {
        HStack(spacing: 12) {
            if layoutDirection == .rightToLeft {
                // RTL: Primary button on RIGHT, Secondary on LEFT
                Button(secondaryTitle) {
                    secondaryAction()
                }
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(12)
                .accessibilityIdentifier("secondaryButton")  // ← ADDED
                
                Button(primaryTitle, role: primaryRole) {
                    primaryAction()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(primaryRole == .destructive ? Color.red : Color.blue)
                .cornerRadius(12)
                .accessibilityIdentifier("primaryButton")  // ← ADDED
            } else {
                // LTR: Secondary button on LEFT, Primary on RIGHT
                Button(secondaryTitle) {
                    secondaryAction()
                }
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(12)
                .accessibilityIdentifier("secondaryButton")  // ← ADDED
                
                Button(primaryTitle, role: primaryRole) {
                    primaryAction()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(primaryRole == .destructive ? Color.red : Color.blue)
                .cornerRadius(12)
                .accessibilityIdentifier("primaryButton")  // ← ADDED
            }
        }
    }
}

// Icon placement adapter for RTL
struct CulturalIconLabel: View {
    let icon: String
    let text: String
    
    @Environment(\.layoutDirection) var layoutDirection
    
    var body: some View {
        HStack(spacing: 8) {
            if layoutDirection == .rightToLeft {
                // RTL: Text first, then icon
                Text(text)
                Image(systemName: icon)
            } else {
                // LTR: Icon first, then text
                Image(systemName: icon)
                Text(text)
            }
        }
    }
}
