//
//  ExternalDisplayManager.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI
import UIKit

class ExternalDisplayManager {
    static let shared = ExternalDisplayManager()
    private var externalWindow: UIWindow?
    private var mainWindowScene: UIWindowScene?
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneWillConnect),
            name: UIScene.willConnectNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sceneDidDisconnect),
            name: UIScene.didDisconnectNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func sceneWillConnect(notification: Notification) {
        guard let windowScene = notification.object as? UIWindowScene else { return }
        
        if mainWindowScene == nil {
            mainWindowScene = windowScene
            return
        }
        
        if windowScene != mainWindowScene {
            DispatchQueue.main.async {
                self.setupExternalDisplay(for: windowScene)
            }
        }
    }
    
    @objc private func sceneDidDisconnect(notification: Notification) {
        DispatchQueue.main.async {
            self.externalWindow?.isHidden = true
            self.externalWindow = nil
        }
    }
    
    private func setupExternalDisplay(for windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        
        let externalView = ExternalDisplayView()
        let hostingController = UIHostingController(rootView: externalView)
        window.rootViewController = hostingController
        window.isHidden = false
        
        self.externalWindow = window
    }
    
    func updateDisplay(transactions: [Transaction], balance: Double) {
        guard let window = externalWindow else { return }
        DispatchQueue.main.async {
            let externalView = ExternalDisplayView(transactions: transactions, balance: balance)
            let hostingController = UIHostingController(rootView: externalView)
            window.rootViewController = hostingController
        }
    }
}

struct ExternalDisplayView: View {
    var transactions: [Transaction] = []
    var balance: Double = 0.0
    
    var totalIncome: Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Financial Tracker")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    Text("Current Balance")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("$\(balance, specifier: "%.2f")")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(balance >= 0 ? .green : .red)
                }
                .padding(60)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.2))
                )
                
                HStack(spacing: 60) {
                    VStack(spacing: 15) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        Text("Income")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        Text("$\(totalIncome, specifier: "%.2f")")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.green.opacity(0.2))
                    )
                    
                    VStack(spacing: 15) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                        Text("Expenses")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        Text("$\(totalExpenses, specifier: "%.2f")")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.red.opacity(0.2))
                    )
                }
                
                Text("\(transactions.count) Transactions")
                    .font(.system(size: 35))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
        }
    }
}
