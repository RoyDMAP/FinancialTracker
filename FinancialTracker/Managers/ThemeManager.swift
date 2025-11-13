//
//  ThemeManager.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/10/25.
//

import SwiftUI

struct AppTheme {
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let backgroundColor: Color
    let cardBackground: Color
    let incomeColor: Color
    let expenseColor: Color
    let backgroundPattern: String?
    
    static func theme(for locale: String) -> AppTheme {
        switch locale {
        case "ar":
            // Arabic theme - warm desert colors
            return AppTheme(
                primaryColor: Color(red: 0.8, green: 0.6, blue: 0.2), // Gold
                secondaryColor: Color(red: 0.6, green: 0.4, blue: 0.2), // Bronze
                accentColor: Color(red: 0.9, green: 0.7, blue: 0.3), // Light gold
                backgroundColor: Color(red: 0.98, green: 0.96, blue: 0.92), // Cream
                cardBackground: Color(red: 1.0, green: 0.98, blue: 0.95), // Light cream
                incomeColor: Color(red: 0.2, green: 0.7, blue: 0.3), // Islamic green
                expenseColor: Color(red: 0.8, green: 0.3, blue: 0.2), // Red
                backgroundPattern: "arabic-pattern"
            )
        case "ja":
            // Japanese theme - zen minimalist
            return AppTheme(
                primaryColor: Color(red: 0.7, green: 0.1, blue: 0.2), // Japanese red
                secondaryColor: Color(red: 0.2, green: 0.2, blue: 0.3), // Dark blue
                accentColor: Color(red: 0.9, green: 0.7, blue: 0.8), // Cherry blossom pink
                backgroundColor: Color(red: 0.98, green: 0.98, blue: 1.0), // White
                cardBackground: Color(red: 0.95, green: 0.95, blue: 0.97), // Light gray
                incomeColor: Color(red: 0.3, green: 0.6, blue: 0.9), // Blue
                expenseColor: Color(red: 0.7, green: 0.1, blue: 0.2), // Red
                backgroundPattern: "sakura-pattern"
            )
        case "es":
            // Spanish theme - vibrant warm colors
            return AppTheme(
                primaryColor: Color(red: 0.9, green: 0.3, blue: 0.2), // Red
                secondaryColor: Color(red: 0.9, green: 0.7, blue: 0.1), // Yellow
                accentColor: Color(red: 0.8, green: 0.4, blue: 0.2), // Orange
                backgroundColor: Color(red: 1.0, green: 0.97, blue: 0.9), // Light yellow
                cardBackground: Color(red: 1.0, green: 0.98, blue: 0.95), // Warm white
                incomeColor: Color(red: 0.2, green: 0.7, blue: 0.3), // Green
                expenseColor: Color(red: 0.9, green: 0.3, blue: 0.2), // Red
                backgroundPattern: "spanish-pattern"
            )
        default:
            // English/Default theme - professional blue
            return AppTheme(
                primaryColor: Color.blue,
                secondaryColor: Color.gray,
                accentColor: Color.cyan,
                backgroundColor: Color(uiColor: .systemGroupedBackground),
                cardBackground: Color(uiColor: .secondarySystemGroupedBackground),
                incomeColor: Color.green,
                expenseColor: Color.red,
                backgroundPattern: nil
            )
        }
    }
    
    static var current: AppTheme {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        return theme(for: locale)
    }
}

// Environment key for theme
struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = AppTheme.current
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// Themed background view
struct ThemedBackground: View {
    let theme: AppTheme
    
    var body: some View {
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            if let pattern = theme.backgroundPattern {
                // Pattern overlay
                GeometryReader { geometry in
                    if pattern == "arabic-pattern" {
                        ArabicPatternView()
                            .opacity(0.05)
                    } else if pattern == "sakura-pattern" {
                        SakuraPatternView()
                            .opacity(0.05)
                    } else if pattern == "spanish-pattern" {
                        SpanishPatternView()
                            .opacity(0.05)
                    }
                }
            }
        }
    }
}

// Arabic geometric pattern
struct ArabicPatternView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let size: CGFloat = 60
                let rows = Int(geometry.size.height / size) + 1
                let cols = Int(geometry.size.width / size) + 1
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * size
                        let y = CGFloat(row) * size
                        
                        // Draw star pattern
                        path.move(to: CGPoint(x: x + size/2, y: y))
                        path.addLine(to: CGPoint(x: x + size/2 + 10, y: y + size/2 - 10))
                        path.addLine(to: CGPoint(x: x + size, y: y + size/2))
                        path.addLine(to: CGPoint(x: x + size/2 + 10, y: y + size/2 + 10))
                        path.addLine(to: CGPoint(x: x + size/2, y: y + size))
                        path.addLine(to: CGPoint(x: x + size/2 - 10, y: y + size/2 + 10))
                        path.addLine(to: CGPoint(x: x, y: y + size/2))
                        path.addLine(to: CGPoint(x: x + size/2 - 10, y: y + size/2 - 10))
                        path.closeSubpath()
                    }
                }
            }
            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        }
    }
}

// Japanese cherry blossom pattern
struct SakuraPatternView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<20) { i in
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 30, height: 30)
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
            }
        }
    }
}

// Spanish tile pattern
struct SpanishPatternView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let size: CGFloat = 50
                let rows = Int(geometry.size.height / size) + 1
                let cols = Int(geometry.size.width / size) + 1
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * size
                        let y = CGFloat(row) * size
                        
                        // Draw diamond tile
                        path.move(to: CGPoint(x: x + size/2, y: y))
                        path.addLine(to: CGPoint(x: x + size, y: y + size/2))
                        path.addLine(to: CGPoint(x: x + size/2, y: y + size))
                        path.addLine(to: CGPoint(x: x, y: y + size/2))
                        path.closeSubpath()
                    }
                }
            }
            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        }
    }
}
