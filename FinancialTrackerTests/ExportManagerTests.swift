//
//  ExportManagerTests.swift
//  FinancialTrackerTests
//
//  Created by Roy Dimapilis on 12/01/25.
//

import XCTest
@testable import FinancialTracker

final class ExportManagerTests: XCTestCase {
    
    // MARK: - CSV Export Test
    
    // Unit Test: Verify CSV export functionality
    func testCSVExportWorks() throws {
        // Create ExportManager
        let exporter = ExportManager()
        
        // Export with empty array 
        let emptyTransactions: [Transaction] = []
        let csv = exporter.exportToCSV(transactions: emptyTransactions)
        
        // Test 1: CSV is created
        XCTAssertFalse(csv.isEmpty, "CSV should not be empty")
        
        // Test 2: CSV has correct headers
        XCTAssertTrue(csv.contains("Title,Amount,Type,Date"), "CSV should have correct headers")
        
        // Test 3: CSV after header
        let lines = csv.components(separatedBy: "\n")
        XCTAssertGreaterThan(lines.count, 0, "CSV should have at least header line")
        
        // Test 4: First line is the header
        XCTAssertEqual(lines[0], "Title,Amount,Type,Date", "First line should be headers")
        
        print("✅ CSV Export Test Passed")
        print("CSV Output:\n\(csv)")
    }
}
