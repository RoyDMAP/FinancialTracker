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
                secondaryButton
                primaryButton
            } else {
                // LTR: Secondary button on LEFT, Primary on RIGHT
                secondaryButton
                primaryButton
            }
        }
    }
    
    // MARK: - Secondary Button (Cancel)
    private var secondaryButton: some View {
        Button(action: {
            secondaryAction()  // ← MUST CALL THE ACTION
        }) {
            Text(secondaryTitle)
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(12)
        }
        .buttonStyle(.plain)  // ← ADD THIS
        .accessibilityIdentifier("secondaryButton")
    }
    
    // MARK: - Primary Button (Save)
    private var primaryButton: some View {
        Button(action: {
            primaryAction()  // ← MUST CALL THE ACTION
        }) {
            Text(primaryTitle)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(primaryRole == .destructive ? Color.red : Color.blue)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)  // ← ADD THIS
        .accessibilityIdentifier("primaryButton")
    }
}

// Icon placement 
struct CulturalIconLabel: View {
    let icon: String
    let text: String
    
    @Environment(\.layoutDirection) var layoutDirection
    
    var body: some View {
        HStack(spacing: 8) {
            if layoutDirection == .rightToLeft {
                Text(text)
                Image(systemName: icon)
            } else {
                Image(systemName: icon)
                Text(text)
            }
        }
    }
}
