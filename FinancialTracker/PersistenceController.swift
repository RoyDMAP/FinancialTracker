//
//  PersistenceController.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/8/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        for i in 0..<10 {
            let transaction = TransactionEntity(context: viewContext)
            transaction.id = UUID()
            transaction.title = i % 2 == 0 ? "Salary" : "Groceries"
            transaction.amount = Double.random(in: 50...500)
            transaction.isIncome = i % 2 == 0
            transaction.date = Date().addingTimeInterval(Double(-i * 86400))
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    // The Core Data container
    let container: NSPersistentContainer
    
    // Initializer
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FinancialTracker")
        
        if inMemory {
            // in-memory store for testing/previews
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Load the persistent stores
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Automatically merge changes from parent context
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Core Data Operations
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data saved successfully")
            } catch {
                let nsError = error as NSError
                print("❌ Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Transaction Operations
    
    func addTransaction(title: String, amount: Double, isIncome: Bool, date: Date) {
        let context = container.viewContext
        let transaction = TransactionEntity(context: context)
        
        transaction.id = UUID()
        transaction.title = title
        transaction.amount = amount
        transaction.isIncome = isIncome
        transaction.date = date
        
        save()
    }
    
    func updateTransaction(_ transaction: TransactionEntity, title: String, amount: Double, isIncome: Bool, date: Date) {
        transaction.title = title
        transaction.amount = amount
        transaction.isIncome = isIncome
        transaction.date = date
        
        save()
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        let context = container.viewContext
        context.delete(transaction)
        save()
    }
    
    func fetchAllTransactions() -> [TransactionEntity] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            let transactions = try context.fetch(fetchRequest)
            print("✅ Fetched \(transactions.count) transactions from Core Data")
            return transactions
        } catch {
            print("❌ Failed to fetch transactions: \(error)")
            return []
        }
    }
    
    func fetchTransactions(for month: Date) -> [TransactionEntity] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        
        let calendar = Calendar.current
        let startOfMonth = calendar.startOfMonth(for: month)
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("❌ Failed to fetch transactions for month: \(error)")
            return []
        }
    }
    
    func deleteAllTransactions() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TransactionEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            save()
            print("✅ All transactions deleted")
        } catch {
            print("❌ Failed to delete all transactions: \(error)")
        }
    }
}
