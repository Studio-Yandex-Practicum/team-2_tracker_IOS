import Foundation

final class ExpensesViewModel {
    
    private var expenses: [Expense] = expensesMockData
    

    var totalAmount: Double {
        return expenses.reduce(0) { $0 + $1.expense }
    }
    
    func addExpense(expense: Expense) {
        expenses.append(expense)
    }
    
    func getExpensesForPeriod(startDate: Date, endDate: Date) -> [Date: [Expense]] {
        let filteredExpenses = expenses.filter { $0.date >= startDate && $0.date <= endDate }
        expenses = filteredExpenses
   
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


