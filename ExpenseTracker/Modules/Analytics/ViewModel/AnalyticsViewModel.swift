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
            UIColor.etGrayBlue,
            UIColor.etGreen,
            UIColor.etBlue,
            UIColor.etYellow,
            UIColor.etPurple
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
    private var categoryColors: [String: UIColor] = [:]
    private var isFiltered = false
    
    // MARK: - Methods
    
    func getColorForCategory(_ category: String, isSubCategory: Bool = false) -> UIColor {
        // Если это подкатегория, используем цвет "Остальные"
        if isSubCategory {
            return .etPurple
        }
        
        // Если это категория "Остальные", используем соответствующий цвет
        if category == AnalyticsConstants.otherCategoriesTitle {
            return .etPurple
        }
        
        // Получаем отсортированные категории
        let sortedCategories = getSortedCategories()
        
        // Находим индекс текущей категории в отсортированном списке
        if let categoryIndex = sortedCategories.firstIndex(of: category) {
            // Используем индекс для выбора цвета из массива
            let availableColors = colorCategory.value
            let colorIndex = categoryIndex % availableColors.count
            return availableColors[colorIndex]
        }
        
        // Если категория не найдена, используем фиолетовый
        return .etPurple
    }
    
    func getAllExpenses() -> [Expense] {
        return expensesByDate.values.flatMap { $0 }
    }
    
    func getExpensesForPeriod(startDate: Date, endDate: Date) -> [Date: [Expense]] {
        return expensesByDate.filter { date, expenses in
            date >= startDate && date <= endDate
        }
    }
    
    func updateExpensesData(with expenses: [Expense]) {
        expensesByCategory = Dictionary(grouping: expenses) { $0.category.name }
        sortCategories()
        
        // Очищаем сохраненные цвета при обновлении данных
        categoryColors.removeAll()
        
        // Обновляем общую сумму для всех расходов
        let totalExpensesAmount = expenses.reduce(Decimal(0)) { $0 + $1.expense }
        totalAmount.value = totalExpensesAmount
    }
    
    func updateExpensesByDate(_ expenses: [Date: [Expense]]) {
        expensesByDate = expenses
        let allExpenses = expenses.values.flatMap { $0 }
        updateExpensesData(with: allExpenses)
    }
    
    func sortCategories() {
        let categories = Array(expensesByCategory.keys)
        sortedCategories = categories.sorted { category1, category2 in
            let sum1 = expensesByCategory[category1]?.reduce(0) { $0 + $1.expense } ?? 0
            let sum2 = expensesByCategory[category2]?.reduce(0) { $0 + $1.expense } ?? 0
            return isAscending ? sum1 < sum2 : sum1 > sum2
        }
    }
    
    func toggleSortOrder() {
        isAscending.toggle()
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
        isFiltered = range != nil
        
        if let range = range {
            let filteredExpenses = getExpensesForDateRange(range)
            updateExpensesData(with: filteredExpenses)
        } else {
            let allExpenses = getAllExpenses()
            updateExpensesData(with: allExpenses)
        }
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
    
    func getIconForCategory(_ category: String, expensesByCategory: [String: [Expense]]) -> Asset.Icon {
        if category == AnalyticsConstants.otherCategoriesTitle {
            return .other
        }
        
        // Получаем первый расход из категории для определения иконки
        if let firstExpense = expensesByCategory[category]?.first {
            return firstExpense.category.icon
        }
        
        return .other
    }
    
    func calculatePeriod(for selectedDate: Date, periodType: PeriodType) -> (Date, Date) {
        let currentCalendar = Calendar.current
        var startDate: Date
        var endDate = selectedDate
        
        switch periodType {
        case .day:
            // Для дня используем только текущую дату
            startDate = currentCalendar.startOfDay(for: selectedDate)
            endDate = startDate
        case .week:
            endDate = selectedDate
            startDate = currentCalendar.date(byAdding: .day, value: -7, to: endDate) ?? selectedDate
        case .month:
            endDate = selectedDate
            if let range = currentCalendar.range(of: .day, in: .month, for: selectedDate),
               let monthStart = currentCalendar.date(byAdding: .day, value: -range.count - 1, to: endDate) {
                startDate = monthStart
            } else {
                startDate = selectedDate
            }
        case .year:
            endDate = selectedDate
            startDate = currentCalendar.date(byAdding: .year, value: -1, to: endDate) ?? selectedDate
        }
        return (startDate, endDate)
    }
    
    func getFilteredExpenses() -> [Expense] {
        var filteredExpenses: [Expense]
        
        if !isFiltered {
            // Если фильтры не применены, возвращаем все расходы
            filteredExpenses = getAllExpenses()
        } else if let dateRange = selectedDateRange {
            filteredExpenses = getExpensesForDateRange(dateRange)
        } else if let periodType = getSelectedPeriodType() {
            filteredExpenses = getExpensesForPeriod(periodType)
        } else {
            filteredExpenses = getAllExpenses()
        }
        
        if let selectedCategories = selectedCategories, !selectedCategories.isEmpty {
            filteredExpenses = filteredExpenses.filter { expense in
                selectedCategories.contains(expense.category.name)
            }
        }
        
        // Обновляем общую сумму для отфильтрованных расходов
        let totalFilteredAmount = filteredExpenses.reduce(Decimal(0)) { $0 + $1.expense }
        totalAmount.value = totalFilteredAmount
        
        return filteredExpenses
    }
    
    func getExpensesForDateRange(_ dateRange: (start: Date, end: Date)) -> [Expense] {
        let startOfDay = Calendar.current.startOfDay(for: dateRange.start)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dateRange.end) ?? dateRange.end
        
        let expensesByDate = getExpensesForPeriod(startDate: startOfDay, endDate: endOfDay)
        return expensesByDate.values.flatMap { $0 }
    }
    
    func getExpensesForPeriod(_ periodType: PeriodType) -> [Expense] {
        let (startDate, endDate) = calculatePeriod(for: dayToday.value, periodType: periodType)
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        let expensesByDate = getExpensesForPeriod(startDate: startOfDay, endDate: endOfDay)
        return expensesByDate.values.flatMap { $0 }
    }
    
    func getSelectedPeriodType() -> PeriodType? {
        // Этот метод теперь будет вызываться из ViewController
        return nil
    }
    
    func setSelectedPeriodType(_ periodType: PeriodType?) {
        // Сохраняем выбранный период
        if let periodType = periodType {
            let (startDate, endDate) = calculatePeriod(for: dayToday.value, periodType: periodType)
            selectedDateRange = (startDate, endDate)
            isFiltered = true
            
            // Обновляем расходы и общую сумму для выбранного периода
            let filteredExpenses = getExpensesForPeriod(periodType)
            updateExpensesData(with: filteredExpenses)
        } else {
            selectedDateRange = nil
            isFiltered = false
            // Возвращаемся к общим расходам
            let allExpenses = getAllExpenses()
            updateExpensesData(with: allExpenses)
        }
    }
    
    func resetFilters() {
        selectedDateRange = nil
        tempDateRange = nil
        selectedCategories = nil
        isFiltered = false
        let allExpenses = getAllExpenses()
        updateExpensesData(with: allExpenses)
    }
    
    // MARK: - Cell Configuration
    
    func getCellModel(for category: String, expensesByCategory: [String: [Expense]], isSubCategory: Bool) -> AnalyticsTableCell.AnalyticsCellModel {
        let categoryExpense = calculateCategoryExpense(category, expensesByCategory: expensesByCategory)
        let percentage = calculatePercentage(for: categoryExpense)
        let color = getColorForCategory(category, isSubCategory: isSubCategory)
        
        return AnalyticsTableCell.AnalyticsCellModel(
            category: category,
            icon: getIconForCategory(category, expensesByCategory: expensesByCategory),
            amount: categoryExpense,
            percentage: percentage,
            color: color,
            currency: currency.value,
            isSubCategory: isSubCategory
        )
    }
    
    private func calculateCategoryExpense(_ category: String, expensesByCategory: [String: [Expense]]) -> Decimal {
        if category == AnalyticsConstants.otherCategoriesTitle {
            // Для категории "Остальные" суммируем расходы всех подкатегорий
            let (_, otherCategories) = getCategoriesForDisplay()
            return otherCategories.reduce(Decimal(0)) { total, subCategory in
                total + (expensesByCategory[subCategory]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0)
            }
        }
        
        // Для остальных категорий считаем как обычно
        return expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
    }
    
    private func calculatePercentage(for categoryExpense: Decimal) -> Double? {
        guard totalAmount.value > 0 else { return nil }
        return Double(truncating: (categoryExpense / totalAmount.value * 100) as NSNumber)
    }
    
    // MARK: - Chart Configuration
    
    func getChartData() -> [(value: Double, color: UIColor)] {
        if getExpensesByCategory().isEmpty {
            return [(1, .etInactive)]
        }
        
        var chartData: [(value: Double, color: UIColor)] = []
        let sortedCategories = getSortedCategories()
        let expensesByCategory = getExpensesByCategory()
        
        // Сортируем категории по сумме расходов (от большей к меньшей)
        let sortedByAmount = sortedCategories.sorted { category1, category2 in
            let amount1 = expensesByCategory[category1]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
            let amount2 = expensesByCategory[category2]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
            return amount1 > amount2
        }
        
        // Вычисляем суммы расходов для каждой категории
        let categoryAmounts = sortedByAmount.map { category -> (category: String, amount: Decimal) in
            let amount = expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
            return (category: category, amount: amount)
        }
        
        // Распределяем категории на основные и "Остальные"
        let (mainCategories, otherCategories) = distributeCategories(categoryAmounts, expensesByCategory: expensesByCategory)
        
        // Получаем общую сумму расходов
        let totalExpense = sortedCategories.reduce(Decimal(0)) { total, category in
            total + (expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0)
        }
        
        // Добавляем первую половину первой категории в начало
        if let firstCategory = mainCategories.first,
           let expenses = expensesByCategory[firstCategory] {
            let categoryAmount = expenses.reduce(Decimal(0)) { $0 + $1.expense }
            let percentage = Double(truncating: categoryAmount as NSDecimalNumber) / Double(truncating: totalExpense as NSDecimalNumber) / 2
            chartData.append((value: percentage, color: getColorForCategory(firstCategory)))
        }
        
        // Добавляем остальные основные категории
        for category in mainCategories.dropFirst() {
            if let expenses = expensesByCategory[category] {
                let categoryAmount = expenses.reduce(Decimal(0)) { $0 + $1.expense }
                let percentage = Double(truncating: categoryAmount as NSDecimalNumber) / Double(truncating: totalExpense as NSDecimalNumber)
                chartData.append((value: percentage, color: getColorForCategory(category)))
            }
        }
        
        // Добавляем "Остальное" и его подкатегории как одну секцию
        if !otherCategories.isEmpty {
            let otherAmount = otherCategories.reduce(Decimal(0)) { total, category in
                total + (expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0)
            }
            let otherPercentage = Double(truncating: otherAmount as NSDecimalNumber) / Double(truncating: totalExpense as NSDecimalNumber)
            chartData.append((value: otherPercentage, color: .etPurple))
        }
        
        // Добавляем вторую половину первой категории в конец
        if let firstCategory = mainCategories.first,
           let expenses = expensesByCategory[firstCategory] {
            let categoryAmount = expenses.reduce(Decimal(0)) { $0 + $1.expense }
            let percentage = Double(truncating: categoryAmount as NSDecimalNumber) / Double(truncating: totalExpense as NSDecimalNumber) / 2
            chartData.append((value: percentage, color: getColorForCategory(firstCategory)))
        }
        
        return chartData
    }
    
    private func distributeCategories(
        _ categoryAmounts: [(category: String, amount: Decimal)],
        expensesByCategory: [String: [Expense]]
    ) -> (mainCategories: [String], otherCategories: [String]) {
        var mainCategories: [String] = []
        var otherCategories: [String] = []
        
        if categoryAmounts.count > 6 {
            mainCategories = Array(categoryAmounts.prefix(5).map { $0.category })
            let otherAmount = categoryAmounts.dropFirst(5).reduce(Decimal(0)) { $0 + $1.amount }
            
            if categoryAmounts.count > 5 {
                let sixthCategoryAmount = categoryAmounts[5].amount
                if otherAmount > sixthCategoryAmount {
                    otherCategories = Array(categoryAmounts.dropFirst(5).map { $0.category })
                } else {
                    mainCategories.append(categoryAmounts[5].category)
                    otherCategories = Array(categoryAmounts.dropFirst(6).map { $0.category })
                }
            }
            
            for i in 1..<mainCategories.count {
                let currentCategory = mainCategories[i]
                let currentAmount = expensesByCategory[currentCategory]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
                
                if otherAmount > currentAmount {
                    otherCategories.insert(currentCategory, at: 0)
                    mainCategories.remove(at: i)
                }
            }
        } else {
            mainCategories = categoryAmounts.map { $0.category }
        }
        
        return (mainCategories, otherCategories)
    }
    
    // MARK: - Table View Methods
    
    func getNumberOfRows() -> Int {
        let (mainCategories, otherCategories) = getCategoriesForDisplay()
        
        // Если категорий 6 или меньше, показываем все категории
        if otherCategories.isEmpty {
            return min(mainCategories.count, 6)
        }
        
        // Иначе показываем все категории, включая "Остальное" и его подкатегории
        return mainCategories.count + 1 + otherCategories.count
    }
    
    func getCategoryForRow(at indexPath: IndexPath) -> (category: String, isSubCategory: Bool) {
        let (mainCategories, otherCategories) = getCategoriesForDisplay()
        let expensesByCategory = getExpensesByCategory()
        
        if getIsAscending() {
            // При сортировке по возрастанию
            if !otherCategories.isEmpty && indexPath.row == 0 {
                // Показываем "Остальное" в начале только если есть больше 6 категорий
                return (AnalyticsConstants.otherCategoriesTitle, false)
            } else if !otherCategories.isEmpty && indexPath.row <= otherCategories.count {
                // Показываем подкатегории "Остального" сразу после него
                return (otherCategories[indexPath.row - 1], true)
            } else {
                // Показываем основные категории, отсортированные по возрастанию
                let mainCategoriesSorted = mainCategories.sorted { category1, category2 in
                    let amount1 = expensesByCategory[category1]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
                    let amount2 = expensesByCategory[category2]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
                    return amount1 < amount2 // Сортировка по возрастанию
                }
                let offset = otherCategories.isEmpty ? 0 : otherCategories.count + 1
                let index = indexPath.row - offset
                if index < mainCategoriesSorted.count {
                    return (mainCategoriesSorted[index], false)
                } else {
                    return (mainCategoriesSorted.last ?? "", false)
                }
            }
        } else {
            // При сортировке по убыванию
            if indexPath.row < mainCategories.count {
                // Показываем основные категории
                return (mainCategories[indexPath.row], false)
            } else if !otherCategories.isEmpty && indexPath.row == mainCategories.count {
                // Показываем "Остальное" только если есть больше 6 категорий
                return (AnalyticsConstants.otherCategoriesTitle, false)
            } else if !otherCategories.isEmpty {
                // Показываем подкатегории "Остального" сразу после него
                let subCategoryIndex = indexPath.row - mainCategories.count - 1
                if subCategoryIndex < otherCategories.count {
                    return (otherCategories[subCategoryIndex], true)
                } else {
                    return (otherCategories.last ?? "", true)
                }
            } else {
                // Если нет дополнительных категорий, показываем следующую основную
                let index = indexPath.row
                if index < mainCategories.count {
                    return (mainCategories[index], false)
                } else {
                    return (mainCategories.last ?? "", false)
                }
            }
        }
    }
    
    private func getCategoriesForDisplay() -> (mainCategories: [String], otherCategories: [String]) {
        let sortedCategories = getSortedCategories()
        let expensesByCategory = getExpensesByCategory()
        
        // Сортируем категории по сумме расходов (от большей к меньшей)
        let sortedByAmount = sortedCategories.sorted { category1, category2 in
            let amount1 = expensesByCategory[category1]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
            let amount2 = expensesByCategory[category2]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
            return amount1 > amount2
        }
        
        // Вычисляем суммы расходов для каждой категории
        let categoryAmounts = sortedByAmount.map { category -> (category: String, amount: Decimal) in
            let amount = expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
            return (category: category, amount: amount)
        }
        
        return distributeCategories(categoryAmounts, expensesByCategory: expensesByCategory)
    }
}
