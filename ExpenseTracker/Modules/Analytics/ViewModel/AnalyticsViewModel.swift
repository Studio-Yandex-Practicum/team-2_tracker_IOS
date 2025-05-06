import Foundation
import UIKit

final class AnalyticsViewModel {
    // MARK: - Observable Properties
    
    let totalAmount = Observable<Decimal>(0)
    let currency = Observable<String>(Currency.ruble.rawValue)
    let dayToday = Observable<Date>(Date(timeIntervalSinceNow: 0))
    let colorCategory = Observable<[UIColor]>(
        [
            UIColor.etbRed,
            UIColor.etOrange,
            UIColor.etGreen,
            UIColor.etBlue,
            UIColor.etPurple,
            UIColor.etPink,
            UIColor.etYellow,
            UIColor.etGrayBlue
        ]
    )
    
    // MARK: - Private Properties
    
    private var expensesByDate: [Date: [Expense]] = [:]
    private var selectedCategories: Set<String>?
    private var selectedDateRange: (start: Date, end: Date)?
    private var tempDateRange: (start: Date, end: Date)?
    private var expensesByCategory: [String: [Expense]] = [:]
    private var sortedCategories: [String] = []
    private var isAscending = false
    
    // MARK: - Methods
    
    func getAllExpenses() -> [Expense] {
        return expensesByDate.values.flatMap { $0 }
    }
    
    func getExpensesForPeriod(startDate: Date, endDate: Date) -> [Date: [Expense]] {
        return expensesByDate.filter { date, expenses in
            date >= startDate && date <= endDate
        }
    }
    
    func updateExpensesData(with expenses: [Expense]) {
        expensesByCategory = Dictionary(grouping: expenses) { $0.category }
        sortCategories()
        totalAmount.value = expenses.reduce(0) { $0 + $1.expense }
    }
    
    func updateExpensesByDate(_ expenses: [Date: [Expense]]) {
        expensesByDate = expenses
        let allExpenses = expenses.values.flatMap { $0 }
        updateExpensesData(with: allExpenses)
    }
    
    func sortCategories() {
        sortedCategories = expensesByCategory.keys.sorted { category1, category2 in
            let sum1 = expensesByCategory[category1]?.reduce(0) { $0 + $1.expense } ?? 0
            let sum2 = expensesByCategory[category2]?.reduce(0) { $0 + $1.expense } ?? 0
            return isAscending ? sum1 < sum2 : sum1 > sum2
        }
    }
    
    func toggleSortOrder() {
        isAscending.toggle()
        sortCategories()
    }
    
    func getSortedCategories() -> [String] {
        return sortedCategories
    }
    
    func getExpensesByCategory() -> [String: [Expense]] {
        return expensesByCategory
    }
    
    func getIsAscending() -> Bool {
        return isAscending
    }
    
    func setSelectedDateRange(_ range: (start: Date, end: Date)?) {
        selectedDateRange = range
    }
    
    func setTempDateRange(_ range: (start: Date, end: Date)?) {
        tempDateRange = range
    }
    
    func getSelectedDateRange() -> (start: Date, end: Date)? {
        return selectedDateRange
    }
    
    func getTempDateRange() -> (start: Date, end: Date)? {
        return tempDateRange
    }
    
    func setSelectedCategories(_ categories: Set<String>?) {
        selectedCategories = categories
    }
    
    func getSelectedCategories() -> Set<String>? {
        return selectedCategories
    }
}
