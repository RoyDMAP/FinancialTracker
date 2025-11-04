//
//  FinancialTrackerApp.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI

@main
struct FinancialTrackerApp: App {
    init() {
        // Initialize external display manager
        _ = ExternalDisplayManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
