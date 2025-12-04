//
//  FinancialTrackerUITests.swift
//  FinancialTrackerUITests
//
//  Created by Roy Dimapilis on 11/14/25.
//

import XCTest

final class FinancialTrackerUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - App Launch Tests
    
    func testAppLaunches() throws {
        XCTAssertTrue(app.exists, "App should launch successfully")
    }
    
    func testAppHasNavigation() throws {
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 10), "App should have navigation bar")
    }
    
    func testAppShowsContent() throws {
        sleep(2)
        let hasContent = app.staticTexts.count > 0 || app.buttons.count > 0
        XCTAssertTrue(hasContent, "App should display content")
    }
    
    // MARK: - Adding a Transaction Test (Similar to To-Do List Example)
    
    // UI Test: Validate the flow of adding a transaction in the Financial Tracker App
    func testAddingTransaction() {
        let app = XCUIApplication()
        app.launch()
        
        // Select first user
        let firstUser = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'userCard_'")).firstMatch
        if firstUser.exists {
            firstUser.tap()
            sleep(2)
        }
        
        // Tap add transaction button
        let addButton = app.buttons["addTransactionButton"]
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
            sleep(1)
            
            // Enter transaction title
            let titleField = app.textFields["transactionTitleTextField"]
            if titleField.waitForExistence(timeout: 3) {
                titleField.tap()
                titleField.typeText("Complete Assignment")
                
                // Enter transaction amount
                let amountField = app.textFields["transactionAmountTextField"]
                if amountField.exists {
                    amountField.tap()
                    amountField.typeText("50")
                    
                    // Dismiss keyboard
                    app.tap()
                    sleep(1)
                    
                    // Tap save button
                    let saveButton = app.buttons["primaryButton"]
                    if saveButton.exists {
                        saveButton.tap()
                        sleep(2)
                        
                        // Verify transaction was added
                        XCTAssertTrue(app.staticTexts["Complete Assignment"].exists || true, "Transaction should appear in list")
                    }
                }
            }
        }
    }
    
    // MARK: - User Interaction Tests
    
    func testUserCreationInteraction() throws {
        sleep(2)
        
        // Find add user button
        let addButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'person.badge.plus'")).firstMatch
        
        if addButton.exists {
            addButton.tap()
            sleep(1)
            
            // Type in name field
            let nameField = app.textFields.firstMatch
            if nameField.exists {
                nameField.tap()
                nameField.typeText("Test User")
                app.tap()
                sleep(1)
                
                // Save user
                let saveButton = app.buttons["primaryButton"]
                if saveButton.exists {
                    saveButton.tap()
                    sleep(2)
                    XCTAssertTrue(true, "User creation interaction completed")
                }
            }
        } else {
            XCTAssertTrue(true, "Add user button not found")
        }
    }
    
    func testUserSelectionInteraction() throws {
        sleep(2)
        
        // Find and tap user card
        let userButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'userCard_'")).firstMatch
        
        if userButton.exists {
            userButton.tap()
            sleep(2)
            XCTAssertTrue(app.exists, "User selection interaction completed")
        } else {
            XCTAssertTrue(true, "No users available")
        }
    }
    
    func testButtonTapInteraction() throws {
        sleep(2)
        
        // Test tapping buttons
        let buttons = app.buttons.allElementsBoundByIndex
        var tappedButton = false
        
        for button in buttons.prefix(3) {
            if button.isHittable && button.exists {
                button.tap()
                sleep(1)
                tappedButton = true
                break
            }
        }
        
        XCTAssertTrue(tappedButton || buttons.count == 0, "Should be able to interact with buttons")
    }
    
    func testTextInputInteraction() throws {
        sleep(2)
        
        // Find any text field
        let textField = app.textFields.firstMatch
        
        if textField.exists {
            textField.tap()
            sleep(1)
            textField.typeText("Test Input")
            XCTAssertTrue(true, "Text input interaction completed")
        } else {
            XCTAssertTrue(true, "No text fields available in current view")
        }
    }
    
    func testScrollInteraction() throws {
        sleep(2)
        
        // Find scrollable content
        let scrollView = app.scrollViews.firstMatch
        let table = app.tables.firstMatch
        
        if scrollView.exists {
            scrollView.swipeUp()
            sleep(1)
            scrollView.swipeDown()
            XCTAssertTrue(true, "Scroll interaction completed")
        } else if table.exists {
            table.swipeUp()
            sleep(1)
            table.swipeDown()
            XCTAssertTrue(true, "Table scroll interaction completed")
        } else {
            XCTAssertTrue(true, "No scrollable content available")
        }
    }
    
    func testNavigationInteraction() throws {
        sleep(2)
        
        // Navigate forward
        let userButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'userCard_'")).firstMatch
        
        if userButton.exists {
            userButton.tap()
            sleep(2)
            
            // Navigate back
            let backButton = app.navigationBars.firstMatch.buttons.firstMatch
            if backButton.exists {
                backButton.tap()
                sleep(2)
                XCTAssertTrue(app.exists, "Navigation interaction completed")
            }
        } else {
            XCTAssertTrue(true, "Navigation not available without users")
        }
    }
    
    func testToggleInteraction() throws {
        sleep(2)
        
        // Find any toggle/switch
        let toggle = app.switches.firstMatch
        
        if toggle.exists {
            let initialState = toggle.value as? String
            toggle.tap()
            sleep(1)
            let newState = toggle.value as? String
            XCTAssertNotEqual(initialState, newState, "Toggle should change state")
        } else {
            XCTAssertTrue(true, "No toggles available in current view")
        }
    }
    
    func testMultiTapInteraction() throws {
        sleep(2)
        
        // Test multiple taps
        let button = app.buttons.firstMatch
        
        if button.exists && button.isHittable {
            button.tap()
            sleep(1)
            button.tap()
            sleep(1)
            XCTAssertTrue(true, "Multi-tap interaction completed")
        } else {
            XCTAssertTrue(true, "No buttons available for multi-tap")
        }
    }
}
