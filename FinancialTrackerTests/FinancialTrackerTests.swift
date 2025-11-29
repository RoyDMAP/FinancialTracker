//
//  FinancialTrackerTests.swift
//  FinancialTrackerTests
//
//  Created by Roy Dimapilis on 11/1/25.
//

import XCTest
@testable import FinancialTracker

final class FinancialTrackerTests: XCTestCase {

    override func setUpWithError() throws {
        // Clean up before each test
    }

    override func tearDownWithError() throws {
        // Clean up after tests
    }

    // MARK: - Transaction Manager Tests (Equivalent to TaskManager)
    
    // Unit Test: Adding a Transaction
    func testAddingTransaction() throws {
        var transactions: [Transaction] = []
        
        let newTransaction = Transaction(
            title: "Buy Groceries",
            amount: 50.0,
            isIncome: false,
            date: Date()
        )
        transactions.append(newTransaction)
        
        XCTAssertEqual(transactions.count, 1, "Should have 1 transaction")
        XCTAssertEqual(transactions[0].title, "Buy Groceries", "Transaction title should match")
    }
    
    func testAddingMultipleTransactions() throws {
        var transactions: [Transaction] = []
        
        transactions.append(Transaction(title: "Groceries", amount: 50.0, isIncome: false, date: Date()))
        transactions.append(Transaction(title: "Gas", amount: 30.0, isIncome: false, date: Date()))
        transactions.append(Transaction(title: "Salary", amount: 2000.0, isIncome: true, date: Date()))
        
        XCTAssertEqual(transactions.count, 3, "Should have 3 transactions")
        XCTAssertEqual(transactions[0].title, "Groceries")
        XCTAssertEqual(transactions[1].title, "Gas")
        XCTAssertEqual(transactions[2].title, "Salary")
    }
    
    func testRemovingTransaction() throws {
        var transactions: [Transaction] = []
        
        let transaction1 = Transaction(title: "Groceries", amount: 50.0, isIncome: false, date: Date())
        let transaction2 = Transaction(title: "Gas", amount: 30.0, isIncome: false, date: Date())
        transactions.append(transaction1)
        transactions.append(transaction2)
        
        transactions.removeAll { $0.id == transaction1.id }
        
        XCTAssertEqual(transactions.count, 1, "Should have 1 transaction after removal")
        XCTAssertEqual(transactions[0].title, "Gas", "Remaining transaction should be Gas")
    }

    // MARK: - Transaction Model Tests
    
    func testTransactionCreation() throws {
        let transaction = Transaction(
            title: "Groceries",
            amount: 50.0,
            isIncome: false,
            date: Date()
        )
        
        XCTAssertEqual(transaction.title, "Groceries")
        XCTAssertEqual(transaction.amountUSD, 50.0)
        XCTAssertFalse(transaction.isIncome)
    }
    
    func testTransactionIncomeCreation() throws {
        let transaction = Transaction(
            title: "Salary",
            amount: 2000.0,
            isIncome: true,
            date: Date()
        )
        
        XCTAssertEqual(transaction.title, "Salary")
        XCTAssertEqual(transaction.amountUSD, 2000.0)
        XCTAssertTrue(transaction.isIncome)
    }
    
    func testTransactionFormattedAmount() throws {
        let transaction = Transaction(
            title: "Test",
            amount: 100.0,
            isIncome: false,
            date: Date()
        )
        
        XCTAssertFalse(transaction.formattedAmount.isEmpty, "Formatted amount should not be empty")
    }
    
    func testTransactionHasValidID() throws {
        let transaction = Transaction(
            title: "Test",
            amount: 50.0,
            isIncome: false,
            date: Date()
        )
        
        XCTAssertNotNil(transaction.id, "Transaction should have an ID")
    }

    // MARK: - User Model Tests
    
    func testUserCreation() throws {
        let user = User(
            name: "Test User",
            emoji: "👤",
            photoData: nil
        )
        
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.emoji, "👤")
        XCTAssertNil(user.photoData)
    }
    
    func testUserWithPhoto() throws {
        let testData = Data([0x00, 0x01, 0x02])
        let user = User(
            name: "Photo User",
            emoji: "👨",
            photoData: testData
        )
        
        XCTAssertEqual(user.name, "Photo User")
        XCTAssertNotNil(user.photoData)
    }
    
    func testUserUniqueID() throws {
        let user1 = User(name: "User 1", emoji: "👤", photoData: nil)
        let user2 = User(name: "User 2", emoji: "👨", photoData: nil)
        
        XCTAssertNotEqual(user1.id, user2.id, "Each user should have unique ID")
    }

    // MARK: - User Manager Tests (Equivalent to TaskManager)
    
    func testAddingUser() throws {
        var users: [User] = []
        
        let newUser = User(name: "John", emoji: "👨", photoData: nil)
        users.append(newUser)
        
        XCTAssertEqual(users.count, 1, "Should have 1 user")
        XCTAssertEqual(users[0].name, "John", "User name should match")
    }
    
    func testRemovingUser() throws {
        var users: [User] = []
        
        let user1 = User(name: "John", emoji: "👨", photoData: nil)
        let user2 = User(name: "Jane", emoji: "👩", photoData: nil)
        users.append(user1)
        users.append(user2)
        
        users.removeAll { $0.id == user1.id }
        
        XCTAssertEqual(users.count, 1, "Should have 1 user after removal")
        XCTAssertEqual(users[0].name, "Jane", "Remaining user should be Jane")
    }

    // MARK: - CurrencyConverter Tests
    
    func testCurrencyConverterSingleton() throws {
        let converter1 = CurrencyConverter.shared
        let converter2 = CurrencyConverter.shared
        
        XCTAssertTrue(converter1 === converter2, "Should be same instance")
    }
    
    func testCurrencyConverterFormat() throws {
        let converter = CurrencyConverter.shared
        
        let formatted = converter.format(100.0)
        XCTAssertFalse(formatted.isEmpty, "Formatted amount should not be empty")
    }
    
    func testCurrencyConverterRoundTrip() throws {
        let converter = CurrencyConverter.shared
        
        let originalAmount = 100.0
        let toUSD = converter.convertToUSD(originalAmount)
        let backToLocal = converter.convertFromUSD(toUSD)
        
        XCTAssertEqual(originalAmount, backToLocal, accuracy: 0.01)
    }
    
    func testCurrencySymbolNotEmpty() throws {
        let converter = CurrencyConverter.shared
        
        XCTAssertFalse(converter.currencySymbol.isEmpty, "Currency symbol should exist")
    }

    // MARK: - Balance Calculation Tests
    
    func testBalanceCalculationIncome() throws {
        let transactions = [
            Transaction(title: "Salary", amount: 1000.0, isIncome: true, date: Date()),
            Transaction(title: "Bonus", amount: 500.0, isIncome: true, date: Date())
        ]
        
        let balance = transactions.reduce(0) { total, transaction in
            total + (transaction.isIncome ? transaction.amountUSD : -transaction.amountUSD)
        }
        
        XCTAssertEqual(balance, 1500.0)
    }
    
    func testBalanceCalculationExpense() throws {
        let transactions = [
            Transaction(title: "Groceries", amount: 100.0, isIncome: false, date: Date()),
            Transaction(title: "Gas", amount: 50.0, isIncome: false, date: Date())
        ]
        
        let balance = transactions.reduce(0) { total, transaction in
            total + (transaction.isIncome ? transaction.amountUSD : -transaction.amountUSD)
        }
        
        XCTAssertEqual(balance, -150.0)
    }
    
    func testBalanceCalculationMixed() throws {
        let transactions = [
            Transaction(title: "Salary", amount: 1000.0, isIncome: true, date: Date()),
            Transaction(title: "Groceries", amount: 100.0, isIncome: false, date: Date())
        ]
        
        let balance = transactions.reduce(0) { total, transaction in
            total + (transaction.isIncome ? transaction.amountUSD : -transaction.amountUSD)
        }
        
        XCTAssertEqual(balance, 900.0)
    }
    
    func testBalanceCalculationEmpty() throws {
        let transactions: [Transaction] = []
        
        let balance = transactions.reduce(0) { total, transaction in
            total + (transaction.isIncome ? transaction.amountUSD : -transaction.amountUSD)
        }
        
        XCTAssertEqual(balance, 0.0)
    }

    // MARK: - AppTheme Tests
    
    func testAppThemeExists() throws {
        let theme = AppTheme.current
        
        XCTAssertNotNil(theme.primaryColor)
        XCTAssertNotNil(theme.incomeColor)
        XCTAssertNotNil(theme.expenseColor)
        XCTAssertNotNil(theme.cardBackground)
    }

    // MARK: - Performance Tests
    
    func testTransactionCreationPerformance() throws {
        measure {
            for i in 0..<100 {
                _ = Transaction(
                    title: "Transaction \(i)",
                    amount: Double(i) * 10.0,
                    isIncome: i % 2 == 0,
                    date: Date()
                )
            }
        }
    }
}
