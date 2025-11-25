//
//  FinancialTrackerApp.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

@main
struct FinancialTrackerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @StateObject private var storeManager = StoreManager()
    
    init() {
        _ = ExternalDisplayManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            UserSelectionView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(\.colorScheme, isDarkMode ? .dark : .light)
                .environmentObject(storeManager)
        }
    }
}
