import CoreData
import Foundation

final class ExpenseService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createExpense(amount: Decimal, date: Date, note: String, category: CategoryModel) {
        let expense = ExpenseModel(context: context)
        expense.id = UUID()
        expense.amount = amount as NSDecimalNumber
        expense.date = date
        expense.note = note
        expense.category = category
        
        saveContext()
    }
    
    func updateExpense(_ expense: ExpenseModel) {
        saveContext()
    }
    
    func deleteExpense(_ expense: ExpenseModel) {
        context.delete(expense)
        saveContext()
    }
    
    func fetchExpenses() -> [ExpenseModel] {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching expenses: \(error)")
            return []
        }
    }
    
    func fetchExpensesForPeriod(startDate: Date, endDate: Date) -> [ExpenseModel] {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
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