//
//  ExternalDisplayManager.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI
import UIKit
import Combine

class ExternalDisplayManager: ObservableObject {
    static let shared = ExternalDisplayManager()
    
    @Published var externalWindow: UIWindow?
    private var externalScene: UIWindowScene?
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidConnect),
            name: UIScreen.didConnectNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidDisconnect),
            name: UIScreen.didDisconnectNotification,
            object: nil
        )
    }
    
    @objc private func screenDidConnect(notification: Notification) {
        guard let screen = notification.object as? UIScreen else { return }
        setupExternalDisplay(screen: screen)
    }
    
    @objc private func screenDidDisconnect(notification: Notification) {
        externalWindow = nil
        externalScene = nil
    }
    
    private func setupExternalDisplay(screen: UIScreen) {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.screen == screen }
        
        guard let scene = windowScene else { return }
        
        self.externalScene = scene
        
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(
            rootView: ExternalDisplayView()
        )
        window.isHidden = false
        
        self.externalWindow = window
    }
    
    func updateDisplay(transactions: [Transaction], balance: Double) {
        guard let window = externalWindow,
              let hostingController = window.rootViewController as? UIHostingController<ExternalDisplayView> else {
            return
        }
        
        // Convert balance to local currency
        let localBalance = CurrencyConverter.shared.convertFromUSD(balance)
        
        hostingController.rootView = ExternalDisplayView(
            transactions: transactions,
            balance: localBalance
        )
    }
}

struct ExternalDisplayView: View {
    var transactions: [Transaction] = []
    var balance: Double = 0.0
    
    var expenses: Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amountUSD }  // Changed from .amount to .amountUSD
    }
    
    var income: Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amountUSD }  // Changed from .amount to .amountUSD
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Financial Overview")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 40) {
                    StatCard(
                        title: "Balance",
                        value: CurrencyConverter.shared.format(balance),
                        color: balance >= 0 ? .green : .red,
                        icon: "dollarsign.circle.fill"
                    )
                    
                    StatCard(
                        title: "Income",
                        value: CurrencyConverter.shared.format(CurrencyConverter.shared.convertFromUSD(income)),
                        color: .green,
                        icon: "arrow.down.circle.fill"
                    )
                    
                    StatCard(
                        title: "Expenses",
                        value: CurrencyConverter.shared.format(CurrencyConverter.shared.convertFromUSD(expenses)),
                        color: .red,
                        icon: "arrow.up.circle.fill"
                    )
                }
                
                Text("\(transactions.count) Transactions")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(50)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 25))
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 300, height: 300)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.2))
                .shadow(color: color.opacity(0.5), radius: 20)
        )
    }
}
