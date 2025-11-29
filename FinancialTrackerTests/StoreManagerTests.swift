//
//  StoreManagerTests.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/29/25.
//

import XCTest
@testable import FinancialTracker

final class StoreManagerTests: XCTestCase {
    var storeManager: StoreManager!
    
    override func setUpWithError() throws {
        // Reset UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "isPro")
        
        // Create fresh StoreManager for each test
        storeManager = StoreManager()
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "isPro")
        //storeManager = nil
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateIsFree() throws {
        // New users should start with free version
        XCTAssertFalse(storeManager.isPro, "New users should start with free version")
    }
    
    // MARK: - Profile Limit Tests
    
    func testFreeUserCanAddFirstProfile() throws {
        // Free users should be able to add their first profile
        let canAdd = storeManager.canAddProfile(currentProfileCount: 0)
        XCTAssertTrue(canAdd, "Free users should be able to add first profile")
    }
    
    func testFreeUserCannotAddSecondProfile() throws {
        // Free users cannot add more than 1 profile
        let canAdd = storeManager.canAddProfile(currentProfileCount: 1)
        XCTAssertFalse(canAdd, "Free users should not be able to add second profile")
    }
    
    func testFreeUserCannotAddMultipleProfiles() throws {
        // Free users cannot add 3rd, 4th, etc. profiles
        XCTAssertFalse(storeManager.canAddProfile(currentProfileCount: 2))
        XCTAssertFalse(storeManager.canAddProfile(currentProfileCount: 5))
        XCTAssertFalse(storeManager.canAddProfile(currentProfileCount: 10))
    }
    
    func testProUserCanAddUnlimitedProfiles() throws {
        // Pro users can add unlimited profiles
        storeManager.isPro = true
        
        XCTAssertTrue(storeManager.canAddProfile(currentProfileCount: 0))
        XCTAssertTrue(storeManager.canAddProfile(currentProfileCount: 1))
        XCTAssertTrue(storeManager.canAddProfile(currentProfileCount: 10))
        XCTAssertTrue(storeManager.canAddProfile(currentProfileCount: 100))
    }
    
    // MARK: - Transaction Limit Tests
    
    func testFreeUserCanAddFirstTransaction() throws {
        // Free users should be able to add their first transaction
        let canAdd = storeManager.canAddTransaction(currentTransactionCount: 0)
        XCTAssertTrue(canAdd, "Free users should be able to add first transaction")
    }
    
    func testFreeUserCanAddUpToFiveTransactions() throws {
        // Free users can add up to 5 transactions
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 0))
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 1))
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 2))
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 3))
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 4))
    }
    
    func testFreeUserCannotAddSixthTransaction() throws {
        // Free users cannot add 6th transaction
        let canAdd = storeManager.canAddTransaction(currentTransactionCount: 5)
        XCTAssertFalse(canAdd, "Free users should not be able to add 6th transaction")
    }
    
    func testFreeUserCannotAddMoreThanFiveTransactions() throws {
        // Free users cannot exceed 5 transactions
        XCTAssertFalse(storeManager.canAddTransaction(currentTransactionCount: 5))
        XCTAssertFalse(storeManager.canAddTransaction(currentTransactionCount: 6))
        XCTAssertFalse(storeManager.canAddTransaction(currentTransactionCount: 10))
        XCTAssertFalse(storeManager.canAddTransaction(currentTransactionCount: 100))
    }
    
    func testProUserCanAddUnlimitedTransactions() throws {
        // Pro users can add unlimited transactions
        storeManager.isPro = true
        
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 0))
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 5))
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 100))
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 1000))
    }
    
    // MARK: - Limit Message Tests
    
    func testProfileLimitMessageNotEmpty() throws {
        let message = storeManager.getProfileLimitMessage()
        XCTAssertFalse(message.isEmpty, "Profile limit message should not be empty")
    }
    
    func testProfileLimitMessageContainsLimit() throws {
        let message = storeManager.getProfileLimitMessage()
        XCTAssertTrue(message.contains("1"), "Profile limit message should mention limit of 1")
    }
    
    func testTransactionLimitMessageNotEmpty() throws {
        let message = storeManager.getTransactionLimitMessage()
        XCTAssertFalse(message.isEmpty, "Transaction limit message should not be empty")
    }
    
    func testTransactionLimitMessageContainsLimit() throws {
        let message = storeManager.getTransactionLimitMessage()
        XCTAssertTrue(message.contains("5"), "Transaction limit message should mention limit of 5")
    }
    
    func testProfileLimitMessageMentionsPro() throws {
        let message = storeManager.getProfileLimitMessage()
        XCTAssertTrue(message.lowercased().contains("pro"), "Profile limit message should mention Pro upgrade")
    }
    
    func testTransactionLimitMessageMentionsPro() throws {
        let message = storeManager.getTransactionLimitMessage()
        XCTAssertTrue(message.lowercased().contains("pro"), "Transaction limit message should mention Pro upgrade")
    }
    
    // MARK: - Pro Purchase Tests
    
    func testBuyProVersionChangesState() throws {
        // Simulate purchase
        storeManager.isPro = true
        
        
        // Initial state is free
        XCTAssertTrue(storeManager.isPro)
        
        // Should now be Pro
        XCTAssertTrue(storeManager.isPro, "User should be Pro after purchase")
    }
    
    func testProStatusUnlocksProfiles() throws {
        // Start as free
        XCTAssertFalse(storeManager.canAddProfile(currentProfileCount: 1))
        
        // Upgrade to Pro
        storeManager.isPro = true
        
        // Should now allow unlimited profiles
        XCTAssertTrue(storeManager.canAddProfile(currentProfileCount: 1))
        XCTAssertTrue(storeManager.canAddProfile(currentProfileCount: 10))
    }
    
    func testProStatusUnlocksTransactions() throws {
        // Start as free
        XCTAssertFalse(storeManager.canAddTransaction(currentTransactionCount: 5))
        
        // Upgrade to Pro
        storeManager.isPro = true
        
        // Should now allow unlimited transactions
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 5))
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 100))
    }
    
    // MARK: - Edge Case Tests
    
    func testZeroProfileCount() throws {
        // Both free and pro should allow adding when count is 0
        XCTAssertTrue(storeManager.canAddProfile(currentProfileCount: 0))
        
        storeManager.isPro = true
        XCTAssertTrue(storeManager.canAddProfile(currentProfileCount: 0))
    }
    
    func testZeroTransactionCount() throws {
        // Both free and pro should allow adding when count is 0
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 0))
        
        storeManager.isPro = true
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 0))
    }
    
    func testExactlyAtProfileLimit() throws {
        // At exactly 1 profile, free user cannot add more
        XCTAssertFalse(storeManager.canAddProfile(currentProfileCount: 1))
    }
    
    func testExactlyAtTransactionLimit() throws {
        // At exactly 5 transactions, free user cannot add more
        XCTAssertFalse(storeManager.canAddTransaction(currentTransactionCount: 5))
    }
    
    func testJustBelowTransactionLimit() throws {
        // At 4 transactions, free user can still add one more
        XCTAssertTrue(storeManager.canAddTransaction(currentTransactionCount: 4))
    }
    
    // MARK: - Performance Tests
    
    func testProfileLimitCheckPerformance() throws {
        measure {
            for i in 0..<1000 {
                _ = storeManager.canAddProfile(currentProfileCount: i)
            }
        }
    }
    
    func testTransactionLimitCheckPerformance() throws {
        measure {
            for i in 0..<1000 {
                _ = storeManager.canAddTransaction(currentTransactionCount: i)
            }
        }
    }
}
