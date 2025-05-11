import Foundation
import CoreData

final class ExpensesViewModel: NSObject {
    
    private let expenseService: ExpenseService
    private var fetchedResultsController: NSFetchedResultsController<ExpenseModel>?
    private var expensesByDate: [Date: [ExpenseModel]] = [:]
    private let context: NSManagedObjectContext
    
    var onExpensesDidChange: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    var totalAmount: Decimal {
        guard let expenses = fetchedResultsController?.fetchedObjects else { return 0 }
        return expenses.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.expenseService = ExpenseService(context: context)
        super.init()
        setupFetchedResultsController(context: context)
    }
    
    private func setupFetchedResultsController(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            updateExpensesByDate()
        } catch {
            print("Error fetching expenses: \(error)")
            onError?(error)
        }
    }
    
    func addExpense(expense: Decimal, category: CategoryMain, date: Date) {
        let categoryModel = CategoryModel(context: context)
        categoryModel.id = UUID()
        categoryModel.name = category.title
        categoryModel.icon = category.icon.rawValue
        
        do {
            expenseService.createExpense(
                amount: expense,
                date: date,
                note: "",
                category: categoryModel
            )
            NotificationCenter.default.post(name: .expensesDidChange, object: nil)
        } catch {
            print("Error creating expense: \(error)")
            onError?(error)
        }
    }
    
    func removeExpense(_ expense: Expense) {
        guard let expenseModel = fetchedResultsController?.fetchedObjects?.first(where: { $0.id == expense.id }) else {
            onError?(NSError(domain: "ExpenseError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Expense not found"]))
            return
        }
        
        do {
            expenseService.deleteExpense(expenseModel)
            NotificationCenter.default.post(name: .expensesDidChange, object: nil)
        } catch {
            print("Error deleting expense: \(error)")
            onError?(error)
        }
    }
    
    func getAllExpenses() -> [ExpenseModel] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func getAllExpensesByDate() -> [Date: [ExpenseModel]] {
        return expensesByDate
    }
    
    func getExpensesForPeriod(startDate: Date, endDate: Date) -> [Date: [ExpenseModel]] {
        let expenses = expenseService.fetchExpensesForPeriod(startDate: startDate, endDate: endDate)
        return Dictionary(grouping: expenses) { Calendar.current.startOfDay(for: $0.date ?? Date()) }
    }
    
    func updateExpense(_ updatedExpense: Expense) {
        guard let expenseModel = fetchedResultsController?.fetchedObjects?.first(where: { $0.id == updatedExpense.id }) else {
            onError?(NSError(domain: "ExpenseError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Expense not found"]))
            return
        }
        
        expenseModel.amount = NSDecimalNumber(decimal: updatedExpense.expense)
        expenseModel.date = updatedExpense.date
        expenseModel.note = updatedExpense.note
        
        let categoryModel = CategoryModel(context: context)
        categoryModel.id = updatedExpense.category.id
        categoryModel.name = updatedExpense.category.name
        categoryModel.icon = updatedExpense.category.icon.rawValue
        expenseModel.category = categoryModel
        
        do {
            expenseService.updateExpense(expenseModel)
            NotificationCenter.default.post(name: .expensesDidChange, object: nil)
        } catch {
            print("Error updating expense: \(error)")
            onError?(error)
        }
    }
    
    private func updateExpensesByDate() {
        guard let expenses = fetchedResultsController?.fetchedObjects else { return }
        expensesByDate = Dictionary(grouping: expenses) { Calendar.current.startOfDay(for: $0.date ?? Date()) }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ExpensesViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateExpensesByDate()
        onExpensesDidChange?()
    }
}
