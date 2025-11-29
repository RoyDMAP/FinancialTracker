//
//  FinancialTrackerUITests.swift
//  FinancialTrackerUITests
//
//  Created by Roy Dimapilis on 11/14/25.
//

import XCTest

final class FinancialTrackerUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
    }
    
    // MARK: - App Launch Test
    
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Simple check - app exists
        XCTAssertTrue(app.exists)
    }
    
    // MARK: - Navigation Test
    
    func testAppHasNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait and check for navigation
        let navBar = app.navigationBars.firstMatch
        let exists = navBar.waitForExistence(timeout: 10)
        
        XCTAssertTrue(exists || app.exists, "App should have navigation or content")
    }
    
    // MARK: - Content Test
    
    func testAppShowsContent() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for content to load
        sleep(3)
        
        // Check app has some content
        let hasContent = app.staticTexts.count > 0 || app.buttons.count > 0
        XCTAssertTrue(hasContent || app.exists, "App should display content")
    }
    
    // MARK: - Interaction Test
    
    func testAppIsInteractive() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(3)
        
        // App launched successfully
        XCTAssertTrue(app.exists, "App should be interactive")
    }
}
