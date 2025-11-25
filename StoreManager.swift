//
//  StoreManager.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/24/25.
//

import SwiftUI
import Combine

class StoreManager: ObservableObject {
    @Published var isPro = false
    
    // Load saved purchase status
    init() {
        self.isPro = UserDefaults.standard.bool(forKey: "isPro")
    }
    
    // Simulate purchasing the pro version
    func buyProVersion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isPro = true
            // Save purchase status
            UserDefaults.standard.set(true, forKey: "isPro")
            print("✅ Pro version purchased!")
        }
    }
    
    // Check if user can add more profiles
    func canAddProfile(currentProfileCount: Int) -> Bool {
        if isPro {
            return true
        } else {
            return currentProfileCount < 1 // Free users can only have 1 profile
        }
    }
    
    // Check if user can add more transactions
    func canAddTransaction(currentTransactionCount: Int) -> Bool {
        if isPro {
            return true
        } else {
            return currentTransactionCount < 5 // Free users can only have 5 transactions
        }
    }
    
    // Get upgrade message for profiles
    func getProfileLimitMessage() -> String {
        return "Free version allows 1 user profile. Upgrade to Pro for unlimited profiles!"
    }
    
    // Get upgrade message for transactions
    func getTransactionLimitMessage() -> String {
        return "Free version allows 5 transactions. Upgrade to Pro for unlimited transactions!"
    }
    
    // Restore purchases (for testing or future IAP integration)
    func restorePurchases() {
        // For now, just check UserDefaults
        self.isPro = UserDefaults.standard.bool(forKey: "isPro")
    }
}
