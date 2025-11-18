//
//  FinancialTrackerUITests.swift
//  FinancialTrackerUITests
//
//  Created by Roy Dimapilis on 11/14/25.


import XCTest

final class FinancialTrackerUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - User Management Tests
    
    func testAddNewUser() throws {
        // Test adding a new user
        let addUserButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'person.badge.plus' OR label CONTAINS 'Add'")).firstMatch
        XCTAssertTrue(addUserButton.waitForExistence(timeout: 5), "Add user button should exist")
        addUserButton.tap()
        
        // Wait for form to appear
        sleep(1)
        
        // Enter user name using accessibility identifier
        let nameTextField = app.textFields["userNameTextField"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 3), "Name text field should exist")
        nameTextField.tap()
        nameTextField.typeText("Test User")
        
        // Tap to dismiss keyboard
        app.tap()
        sleep(1)
        
        // Save user using primary button
        let saveButton = app.buttons["primaryButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save button should exist")
        saveButton.tap()
        
        // Verify user was created
        sleep(2)
        let userCard = app.staticTexts["Test User"]
        XCTAssertTrue(userCard.waitForExistence(timeout: 5), "User card should appear after creation")
    }
    
    func testSelectUser() throws {
        // Check if users exist, if not create one
        sleep(1)
        let userCards = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'userCard_'"))
        
        if userCards.count == 0 {
            // Create a user first
            try testAddNewUser()
            sleep(1)
        }
        
        // Select first available user
        let firstUser = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'userCard_'")).firstMatch
        XCTAssertTrue(firstUser.waitForExistence(timeout: 3), "At least one user should exist")
        firstUser.tap()
        
        // Verify we're in the main app by looking for transaction list
        sleep(2)
        let addTransactionButton = app.buttons["addTransactionButton"]
        XCTAssertTrue(addTransactionButton.waitForExistence(timeout: 5), "Should navigate to main app")
    }
    
    // MARK: - Transaction Tests
    
    func testAddTransaction() throws {
        // Ensure we have a user and are logged in
        try testSelectUser()
        sleep(1)
        
        // Tap add transaction button
        let addButton = app.buttons["addTransactionButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add transaction button should exist")
        addButton.tap()
        
        sleep(1)
        
        // Enter transaction details using accessibility identifiers
        let titleField = app.textFields["transactionTitleTextField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3), "Title field should exist")
        titleField.tap()
        titleField.typeText("Test Groceries")
        
        let amountField = app.textFields["transactionAmountTextField"]
        XCTAssertTrue(amountField.waitForExistence(timeout: 2), "Amount field should exist")
        amountField.tap()
        amountField.typeText("50")
        
        // Make sure it's an expense (toggle should be off)
        let incomeToggle = app.switches["incomeToggle"]
        if incomeToggle.exists {
            let toggleValue = incomeToggle.value as? String
            if toggleValue == "1" {
                incomeToggle.tap()
            }
        }
        
        // Tap to dismiss keyboard
        app.tap()
        sleep(1)
        
        // Save transaction
        let saveButton = app.buttons["primaryButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2), "Save button should exist")
        saveButton.tap()
        
        // Verify transaction appears
        sleep(2)
        let transactionRow = app.staticTexts["Test Groceries"]
        XCTAssertTrue(transactionRow.waitForExistence(timeout: 5), "Transaction should appear in list")
    }
    
    func testAddIncomeTransaction() throws {
        // Ensure we have a user and are logged in
        try testSelectUser()
        sleep(1)
        
        // Tap add transaction button
        let addButton = app.buttons["addTransactionButton"]
        addButton.tap()
        sleep(1)
        
        // Enter transaction details
        let titleField = app.textFields["transactionTitleTextField"]
        titleField.tap()
        titleField.typeText("Test Salary")
        
        let amountField = app.textFields["transactionAmountTextField"]
        amountField.tap()
        amountField.typeText("2000")
        
        // Toggle to income
        let incomeToggle = app.switches["incomeToggle"]
        if incomeToggle.exists {
            let toggleValue = incomeToggle.value as? String
            if toggleValue == "0" {
                incomeToggle.tap()
            }
        }
        
        // Tap to dismiss keyboard
        app.tap()
        sleep(1)
        
        // Save transaction
        let saveButton = app.buttons["primaryButton"]
        saveButton.tap()
        
        // Verify transaction appears
        sleep(2)
        let transactionRow = app.staticTexts["Test Salary"]
        XCTAssertTrue(transactionRow.waitForExistence(timeout: 5), "Income transaction should appear")
    }
    
    func testViewTransactionDetails() throws {
        // Add a transaction first
        try testAddTransaction()
        sleep(1)
        
        // Tap on the transaction
        let transactionRow = app.staticTexts["Test Groceries"]
        if transactionRow.exists {
            transactionRow.tap()
            sleep(1)
            
            // Verify detail view appears - look for Edit and Delete buttons
            let editButton = app.buttons["editTransactionButton"]
            XCTAssertTrue(editButton.waitForExistence(timeout: 3), "Edit button should exist in detail view")
            
            let deleteButton = app.buttons["deleteTransactionButton"]
            XCTAssertTrue(deleteButton.waitForExistence(timeout: 2), "Delete button should exist in detail view")
        } else {
            XCTFail("Transaction not found for viewing details")
        }
    }
    
    func testDeleteTransaction() throws {
        // Add a transaction first
        try testAddTransaction()
        sleep(1)
        
        // Tap on the transaction
        let transactionRow = app.staticTexts["Test Groceries"]
        XCTAssertTrue(transactionRow.exists, "Transaction should exist")
        transactionRow.tap()
        sleep(1)
        
        // Tap delete button
        let deleteButton = app.buttons["deleteTransactionButton"]
        if deleteButton.exists {
            deleteButton.tap()
            sleep(2)
            
            // Transaction should be removed from list
            XCTAssertFalse(transactionRow.exists, "Transaction should be deleted")
        } else {
            XCTFail("Delete button not found")
        }
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
