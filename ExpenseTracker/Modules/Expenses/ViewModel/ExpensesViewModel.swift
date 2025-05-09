import Foundation

final class ExpensesViewModel {
    
    private var expenses: [Expense] = expensesMockData
    
    var totalAmount: Decimal {
        return expenses.reduce(0) { $0 + $1.expense }
    }
    
    func addExpense(expense: Expense) {
        expenses.append(expense)
    }
    
    func removeExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
    }
    
    func getAllExpenses() -> [Expense] {
        return expenses
    }
    
    func getAllExpensesByDate() -> [Date: [Expense]] {
        var expensesByDate: [Date: [Expense]] = [:]
        
        for expense in expenses {
            let dateKey = Calendar.current.startOfDay(for: expense.date)
            if expensesByDate[dateKey] == nil {
                expensesByDate[dateKey] = []
            }
            expensesByDate[dateKey]?.append(expense)
        }
        return expensesByDate
    }
    
    func getExpensesForPeriod(startDate: Date, endDate: Date) -> [Date: [Expense]] {
        let filteredExpenses = expenses.filter {
            return $0.date >= startDate && $0.date <= endDate
        }
   
        var expensesByDate: [Date: [Expense]] = [:]
        
        for expense in filteredExpenses {
            let dateKey = Calendar.current.startOfDay(for: expense.date)
            if expensesByDate[dateKey] == nil {
                expensesByDate[dateKey] = []
            }
            expensesByDate[dateKey]?.append(expense)
        }
        return expensesByDate
    }
}
