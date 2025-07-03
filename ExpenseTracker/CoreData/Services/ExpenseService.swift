import CoreData
import Foundation
import FirebaseAuth

final class ExpenseService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createExpense(amount: Decimal, date: Date, note: String, category: CategoryModel) {
        let expense = ExpenseModel(context: context)
        expense.id = UUID()
        expense.amount = NSDecimalNumber(decimal: amount)
        expense.date = date
        expense.note = note
        expense.category = category
        expense.userID = Auth.auth().currentUser?.uid
        
        do {
            try context.save()
        } catch {
            print("Error saving expense: \(error)")
            context.rollback()
        }
    }
    
    func updateExpense(_ expense: ExpenseModel) {
        do {
            try context.save()
        } catch {
            print("Error updating expense: \(error)")
            context.rollback()
        }
    }
    
    func deleteExpense(_ expense: ExpenseModel) {
        context.delete(expense)
        do {
            try context.save()
        } catch {
            print("Error deleting expense: \(error)")
            context.rollback()
        }
    }
    
    func fetchExpenses() -> [ExpenseModel] {
        let fetchRequest: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
        
        // Добавляем предикат для фильтрации по userID
        if let currentUserID = Auth.auth().currentUser?.uid {
            fetchRequest.predicate = NSPredicate(format: "userID == %@", currentUserID)
        }
        
        do {
            let expenses = try context.fetch(fetchRequest)
            return expenses
        } catch {
            print("Error fetching expenses: \(error)")
            return []
        }
    }
    
    func fetchExpensesForPeriod(startDate: Date, endDate: Date) -> [ExpenseModel] {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
        
        // Добавляем предикат для фильтрации по userID и периоду
        if let currentUserID = Auth.auth().currentUser?.uid {
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND userID == %@", 
                startDate as NSDate, 
                endDate as NSDate,
                currentUserID
            )
        } else {
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", 
                startDate as NSDate, 
                endDate as NSDate
            )
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching expenses for period: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
} 
