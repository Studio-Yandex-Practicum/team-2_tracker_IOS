import UIKit
import SwiftUICore

final class AnalyticsViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: AnalyticsCoordinator?
    private let viewModel: AnalyticsViewModel
    private let expensesViewModel: ExpensesViewModel
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = AnalyticsConstants.dateFormat
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private var isOtherExpanded = false
    
    // MARK: - UI Components
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textColor = UIColor.etPrimaryLabel
        dateLabel.text = AnalyticsConstants.exampleCategoriesTitle
        dateLabel.textAlignment = .center
        dateLabel.font = AppTextStyle.h2.font
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    
    private lazy var labelMoney: UILabel = {
        let labelMoney = UILabel()
        labelMoney.textColor = .etPrimaryLabel
        labelMoney.font = AppTextStyle.h1.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        return labelMoney
    }()

    private let donutChartView: DonutChartUIKitView = {
        let view = DonutChartUIKitView()
        view.translatesAutoresizingMaskIntoConstraints = false
       
        return view
    }()
    
    private let expenseCategoryTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .etBackground
        tableView.sectionHeaderTopPadding = 0
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var sortedCategoryButton: FiltersButton = {
        let image = UIImage(named: Asset.Icon.arrowSortDown.rawValue)?.withTintColor(.etPrimaryLabel)
        let categoryButton = FiltersButton(title: AnalyticsConstants.sortButtonTitle, image: image ?? UIImage())
        categoryButton.titleLabel?.applyTextStyle(.body, textStyle: .body)
        categoryButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        return categoryButton
    }()
    
    private lazy var calendarStack: UIStackView = {
        let calendarStack = UIStackView()
        calendarStack.spacing = 10
        calendarStack.distribution = .fillEqually
        calendarStack.axis = .horizontal
        calendarStack.translatesAutoresizingMaskIntoConstraints = false
        return calendarStack
    }()
    
    private lazy var calendarButton: CalendarButton = {
        let calendarButton = CalendarButton(backgroundColor: .etBackground)
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        return calendarButton
    }()
    
    private lazy var dayButton: TimeButton = {
        let dayButton = TimeButton(title: ButtonTitel.day.rawValue)
        dayButton.addTarget(self, action: #selector(dayButtonTapped), for: .touchUpInside)
        return dayButton
    }()
    
    private lazy var weekButton: TimeButton = {
        let weekButton = TimeButton(title: ButtonTitel.week.rawValue)
        weekButton.addTarget(self, action: #selector(weekButtonTapped), for: .touchUpInside)
        return weekButton
    }()
    
    private lazy var monthButton: TimeButton = {
        let monthButton = TimeButton(title: ButtonTitel.month.rawValue)
        monthButton.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
        return monthButton
    }()
    
    private lazy var yearButton: TimeButton = {
        let yearButton = TimeButton(title: ButtonTitel.year.rawValue)
        yearButton.addTarget(self, action: #selector(yearButtonTapped), for: .touchUpInside)
        return yearButton
    }()
    
    private let noExpensesLabel: UILabel = {
        let noExpensesLabel = UILabel()
        noExpensesLabel.text = AnalyticsConstants.noExpensesMessage
        noExpensesLabel.textColor = .etPrimaryLabel
        noExpensesLabel.font = AppTextStyle.h2.font
        noExpensesLabel.textAlignment = .center
        noExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        return noExpensesLabel
    }()
    
    private let addExpensesLabel: UILabel = {
        let addExpensesLabel = UILabel()
        addExpensesLabel.text = AnalyticsConstants.addExpensesMessage
        addExpensesLabel.textColor = .etPrimaryLabel
        addExpensesLabel.font = AppTextStyle.body.font
        addExpensesLabel.numberOfLines = 2
        addExpensesLabel.textAlignment = .center
        addExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        return addExpensesLabel
    }()
    
    // MARK: - Initialization
    
    init(viewModel: AnalyticsViewModel, expensesViewmModel: ExpensesViewModel) {
        self.viewModel = viewModel
        self.expensesViewModel = expensesViewmModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        expenseCategoryTable.register(AnalyticsTableCell.self, forCellReuseIdentifier: "ExpenseCategoryCell")
        expenseCategoryTable.delegate = self
        expenseCategoryTable.dataSource = self
        addSubviews()
        setupLayout()
    }
    
    private func setupBindings() {
        // Привязываем обновление UI к изменениям в ViewModel
        viewModel.totalAmount.bind { [weak self] amount in
            self?.updateMoneyLabel(with: amount)
        }
        
        viewModel.currency.bind { [weak self] _ in
            self?.updateMoneyLabel(with: self?.viewModel.totalAmount.value ?? 0)
        }
        
        viewModel.dayToday.bind { [weak self] _ in
            self?.updateDateLabel()
        }
    }
    
    private func loadInitialData() {
        // Получаем данные из ExpensesViewController
        let expensesByDate = expensesViewModel.getAllExpensesByDate()
        viewModel.updateExpensesByDate(expensesByDate)
        
        // Обновляем UI
        updateDonutChart()
        updateMoneyLabel(with: viewModel.totalAmount.value)
        updateDateLabel()
        expenseCategoryTable.reloadData()
        
        // Показываем таблицу или пустое состояние
        if viewModel.getExpensesByCategory().isEmpty {
            showEmptyState()
        } else {
            showTableState()
        }
    }
    
    // MARK: - UI Updates
    
    private func updateMoneyLabel(with amount: Decimal) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if viewModel.getExpensesByCategory().isEmpty {
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 0
        } else {
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
        }
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = ","
        
        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: amount)) {
            labelMoney.text = formattedAmount + " " + viewModel.currency.value
        }
    }
    
    private func updateDateLabel() {
        if let dateRange = viewModel.getSelectedDateRange() {
            let startDate = dateFormatter.string(from: dateRange.start)
            let endDate = dateFormatter.string(from: dateRange.end)
            dateLabel.text = startDate + " - " + endDate
        } else if let periodType = getSelectedPeriodType() {
            let (startDate, endDate) = calculatePeriod(for: viewModel.dayToday.value, periodType: periodType)
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                dateLabel.text = startDateString
            } else {
                dateLabel.text = startDateString + " - " + endDateString
            }
        } else {
            dateLabel.text = AnalyticsConstants.analyticsTitle
        }
    }
    
    private func updateUI(with expenses: [Expense]) {
        if viewModel.getExpensesByCategory().isEmpty {
            showEmptyState()
        } else {
            showTableState()
        }
    }
    
    private func showEmptyState() {
        if expenseCategoryTable.superview != nil {
            expenseCategoryTable.removeFromSuperview()
        }
        if noExpensesLabel.superview == nil {
            view.addSubview(noExpensesLabel)
            view.addSubview(addExpensesLabel)
            setupEmptyStateConstraints()
        }
        // Обновляем диаграмму для пустого состояния
        let data: [(value: Double, color: UIColor)] = [(1, .etInactive)]
        donutChartView.configure(with: data, size: AnalyticsConstants.donutChartSize, lineWidth: AnalyticsConstants.donutChartLineWidth, overlapAngle: 0)
        animateDonutChart()
    }
    
    private func showTableState() {
        if noExpensesLabel.superview != nil {
            noExpensesLabel.removeFromSuperview()
            addExpensesLabel.removeFromSuperview()
        }
        if expenseCategoryTable.superview == nil {
            view.addSubview(expenseCategoryTable)
            setupTableConstraints()
        }
        updateDonutChart()
        expenseCategoryTable.reloadData()
    }
    
    private func updateDonutChart() {
        if viewModel.getExpensesByCategory().isEmpty {
            // Если нет данных, показываем неактивную диаграмму
            let data: [(value: Double, color: UIColor)] = [(1, .etInactive)]
            donutChartView.configure(with: data, size: AnalyticsConstants.donutChartSize, lineWidth: AnalyticsConstants.donutChartLineWidth, overlapAngle: 0)
            return
        }
        
        var chartData: [(value: Double, color: UIColor)] = []
        let sortedCategories = viewModel.getSortedCategories()
        let expensesByCategory = viewModel.getExpensesByCategory()
        
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
        var mainCategories: [String] = []
        var otherCategories: [String] = []
        
        if categoryAmounts.count > 6 {
            // Берем первые 5 категорий как основные
            mainCategories = Array(categoryAmounts.prefix(5).map { $0.category })
            
            // Вычисляем сумму расходов для "Остальных"
            let otherAmount = categoryAmounts.dropFirst(5).reduce(Decimal(0)) { $0 + $1.amount }
            
            // Проверяем, нужно ли добавить 6-ю категорию в "Остальные"
            if categoryAmounts.count > 5 {
                let sixthCategoryAmount = categoryAmounts[5].amount
                if otherAmount > sixthCategoryAmount {
                    // Если сумма "Остальных" больше 6-й категории, добавляем её в "Остальные"
                    otherCategories = Array(categoryAmounts.dropFirst(5).map { $0.category })
                } else {
                    // Иначе добавляем 6-ю категорию в основные
                    mainCategories.append(categoryAmounts[5].category)
                    otherCategories = Array(categoryAmounts.dropFirst(6).map { $0.category })
                }
            }
            
            // Проверяем каждую основную категорию (кроме первой)
            for i in 1..<mainCategories.count {
                let currentCategory = mainCategories[i]
                let currentAmount = expensesByCategory[currentCategory]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
                
                // Если сумма "Остальных" больше текущей категории
                if otherAmount > currentAmount {
                    // Перемещаем текущую категорию в "Остальные"
                    otherCategories.insert(currentCategory, at: 0)
                    mainCategories.remove(at: i)
                }
            }
        } else {
            // Если категорий 6 или меньше, все они основные
            mainCategories = sortedByAmount
        }
        
        // Получаем общую сумму расходов
        let totalExpense = sortedCategories.reduce(Decimal(0)) { total, category in
            total + (expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0)
        }
        
        // Добавляем основные категории
        for category in mainCategories {
            if let expenses = expensesByCategory[category] {
                let categoryAmount = expenses.reduce(Decimal(0)) { $0 + $1.expense }
                let percentage = Double(truncating: categoryAmount as NSDecimalNumber) / Double(truncating: totalExpense as NSDecimalNumber)
                chartData.append((value: percentage, color: viewModel.getColorForCategory(category)))
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
        
        donutChartView.configure(with: chartData, overlapAngle: AnalyticsConstants.donutChartOverlapAngle)
        animateDonutChart()
    }
    
    private func animateDonutChart() {
        // Сбрасываем трансформацию
        donutChartView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        donutChartView.alpha = 0
        
        // Анимируем появление
        UIView.animate(withDuration: 0.5,
                      delay: 0,
                      usingSpringWithDamping: 0.7,
                      initialSpringVelocity: 0.5,
                      options: .curveEaseOut,
                      animations: {
            self.donutChartView.transform = .identity
            self.donutChartView.alpha = 1
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateDonutChart()
    }
    
    // MARK: - Filter Methods
    
    private func setupFilterButtonState(for button: UIButton, with period: PeriodType) {
        button.isSelected.toggle()
        [dayButton, weekButton, monthButton, yearButton].forEach {
            $0.backgroundColor = button == $0 && $0.isSelected ? .etAccent : .etCardsToggled
            let titleColor = button == $0 && $0.isSelected ? UIColor.etButtonLabel : UIColor.etCards
            $0.setTitleColor(titleColor, for: .normal)
            
            if button != $0 {
                $0.isSelected = false
            }
        }
        filterExpenses()
    }
    
    private func filterExpenses() {
        let filteredExpenses = getFilteredExpenses()
        viewModel.updateExpensesData(with: filteredExpenses)
        updateUI(with: filteredExpenses)
        updateDateLabel()
        reloadTable()
    }
    
    private func getFilteredExpenses() -> [Expense] {
        var filteredExpenses: [Expense]
        
        // Получаем расходы в зависимости от выбранного периода
        if let dateRange = viewModel.getSelectedDateRange() {
            filteredExpenses = getExpensesForDateRange(dateRange)
            calendarButton.setImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etAccent), for: .normal)
        } else if let periodType = getSelectedPeriodType() {
            filteredExpenses = getExpensesForPeriod(periodType)
            calendarButton.setImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etCards), for: .normal)
        } else {
            filteredExpenses = viewModel.getAllExpenses()
            calendarButton.setImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etCards), for: .normal)
        }
        
        // Фильтрация по категориям
        if let selectedCategories = viewModel.getSelectedCategories(), !selectedCategories.isEmpty {
            filteredExpenses = filteredExpenses.filter { expense in
                selectedCategories.contains(expense.category.name)
            }
        }
        
        return filteredExpenses
    }
    
    private func getExpensesForDateRange(_ dateRange: (start: Date, end: Date)) -> [Expense] {
        let startOfDay = Calendar.current.startOfDay(for: dateRange.start)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dateRange.end) ?? dateRange.end
        
        let expensesByDate = viewModel.getExpensesForPeriod(startDate: startOfDay, endDate: endOfDay)
        return expensesByDate.values.flatMap { $0 }
    }
    
    private func getExpensesForPeriod(_ periodType: PeriodType) -> [Expense] {
        let (startDate, endDate) = calculatePeriod(for: viewModel.dayToday.value, periodType: periodType)
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        let expensesByDate = viewModel.getExpensesForPeriod(startDate: startOfDay, endDate: endOfDay)
        return expensesByDate.values.flatMap { $0 }
    }
    
    private func calculatePeriod(for selectedDate: Date, periodType: PeriodType) -> (Date, Date) {
        let currentCalendar = Calendar.current
        var startDate: Date
        var endDate = selectedDate
        
        switch periodType {
        case .day:
            startDate = currentCalendar.startOfDay(for: selectedDate)
            endDate = selectedDate
        case .week:
            endDate = selectedDate
            // Находим начало недели, отнимая 6 дней от текущего дня
            startDate = currentCalendar.date(byAdding: .day, value: -7, to: endDate) ?? selectedDate
        case .month:
            endDate = selectedDate
            // Находим начало месяца, отнимая от текущего дня количество дней в месяце
            if let range = currentCalendar.range(of: .day, in: .month, for: selectedDate),
               let monthStart = currentCalendar.date(byAdding: .day, value: -range.count - 1, to: endDate) {
                startDate = monthStart
            } else {
                startDate = selectedDate
            }
        case .year:
            endDate = selectedDate
            // Находим год, отнимая от текущего дня год
            startDate = currentCalendar.date(byAdding: .year, value: -1, to: endDate) ?? selectedDate
        }
        return (startDate, endDate)
    }
    
    private func getSelectedPeriodType() -> PeriodType? {
        if dayButton.isSelected { return .day }
        if weekButton.isSelected { return .week }
        if monthButton.isSelected { return .month }
        if yearButton.isSelected { return .year }
        return nil
    }
    
    private func addSubviews() {
        view.addSubview(dateLabel)
        view.addSubview(labelMoney)
        view.addSubview(donutChartView)
        view.addSubview(calendarButton)
        view.addSubview(calendarStack)
        view.addSubview(sortedCategoryButton)
        
        calendarStack.addArrangedSubview(dayButton)
        calendarStack.addArrangedSubview(weekButton)
        calendarStack.addArrangedSubview(monthButton)
        calendarStack.addArrangedSubview(yearButton)
        
        // Добавляем таблицу или сообщение в зависимости от наличия данных
        if viewModel.getExpensesByCategory().isEmpty {
            view.addSubview(noExpensesLabel)
            view.addSubview(addExpensesLabel)
        } else {
            view.addSubview(expenseCategoryTable)
        }
    }

    private func setupLayout() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        var constraints = [
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            
            labelMoney.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            labelMoney.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelMoney.heightAnchor.constraint(equalToConstant: 28),
            
            donutChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            donutChartView.topAnchor.constraint(equalTo: labelMoney.bottomAnchor, constant: 8),
            donutChartView.widthAnchor.constraint(equalToConstant: 130),
            donutChartView.heightAnchor.constraint(equalToConstant: 130),
            
            calendarButton.topAnchor.constraint(equalTo: donutChartView.bottomAnchor, constant: 12),
            calendarButton.heightAnchor.constraint(equalToConstant: 24),
            calendarButton.widthAnchor.constraint(equalToConstant: 24),
            calendarButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            calendarStack.topAnchor.constraint(equalTo: donutChartView.bottomAnchor, constant: 12),
            calendarStack.heightAnchor.constraint(equalToConstant: 28),
            calendarStack.leadingAnchor.constraint(equalTo: calendarButton.trailingAnchor, constant: 10),
            calendarStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            sortedCategoryButton.topAnchor.constraint(equalTo: calendarButton.bottomAnchor, constant: 18),
            sortedCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6)
        ]
        
        if viewModel.getExpensesByCategory().isEmpty {
            constraints += [
                noExpensesLabel.topAnchor.constraint(equalTo: sortedCategoryButton.bottomAnchor, constant: 96),
                noExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                noExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                
                addExpensesLabel.topAnchor.constraint(equalTo: noExpensesLabel.bottomAnchor, constant: 8),
                addExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                addExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
            ]
        } else {
            constraints += [
                expenseCategoryTable.topAnchor.constraint(equalTo: sortedCategoryButton.bottomAnchor, constant: 12),
                expenseCategoryTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                expenseCategoryTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                expenseCategoryTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ]
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupEmptyStateConstraints() {
        noExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        addExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noExpensesLabel.topAnchor.constraint(equalTo: sortedCategoryButton.bottomAnchor, constant: 96),
            noExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            noExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            addExpensesLabel.topAnchor.constraint(equalTo: noExpensesLabel.bottomAnchor, constant: 8),
            addExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            addExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func setupTableConstraints() {
        expenseCategoryTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            expenseCategoryTable.topAnchor.constraint(equalTo: sortedCategoryButton.bottomAnchor, constant: 12),
            expenseCategoryTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            expenseCategoryTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            expenseCategoryTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func reloadTable() {
        expenseCategoryTable.reloadData()
        updateDonutChart()
    }
    
    private func resetPeriodButtons() {
        [dayButton, weekButton, monthButton, yearButton].forEach {
            $0.isSelected = false
            $0.backgroundColor = .etCardsToggled
            $0.setTitleColor(.etCards, for: .normal)
        }
    }
    
    private func configureCell(_ cell: AnalyticsTableCell, at indexPath: IndexPath) {
        let sortedCategories = viewModel.getSortedCategories()
        let expensesByCategory = viewModel.getExpensesByCategory()
        
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
        var mainCategories: [String] = []
        var otherCategories: [String] = []
        
        if categoryAmounts.count > 6 {
            // Берем первые 5 категорий как основные
            mainCategories = Array(categoryAmounts.prefix(5).map { $0.category })
            
            // Вычисляем сумму расходов для "Остальных"
            let otherAmount = categoryAmounts.dropFirst(5).reduce(Decimal(0)) { $0 + $1.amount }
            
            // Проверяем, нужно ли добавить 6-ю категорию в "Остальные"
            if categoryAmounts.count > 5 {
                let sixthCategoryAmount = categoryAmounts[5].amount
                if otherAmount > sixthCategoryAmount {
                    // Если сумма "Остальных" больше 6-й категории, добавляем её в "Остальные"
                    otherCategories = Array(categoryAmounts.dropFirst(5).map { $0.category })
                } else {
                    // Иначе добавляем 6-ю категорию в основные
                    mainCategories.append(categoryAmounts[5].category)
                    otherCategories = Array(categoryAmounts.dropFirst(6).map { $0.category })
                }
            }
            
            // Проверяем каждую основную категорию (кроме первой)
            for i in 1..<mainCategories.count {
                let currentCategory = mainCategories[i]
                let currentAmount = expensesByCategory[currentCategory]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
                
                // Если сумма "Остальных" больше текущей категории
                if otherAmount > currentAmount {
                    // Перемещаем текущую категорию в "Остальные"
                    otherCategories.insert(currentCategory, at: 0)
                    mainCategories.remove(at: i)
                }
            }
        } else {
            // Если категорий 6 или меньше, все они основные
            mainCategories = sortedByAmount
        }
        
        // Получаем общую сумму расходов
        let totalExpense = sortedCategories.reduce(Decimal(0)) { total, category in
            total + (expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0)
        }
        
        // Определяем, какую категорию показывать
        let category: String
        let isOtherCategory: Bool
        let isSubCategory: Bool
        
        if viewModel.getIsAscending() {
            // При сортировке по возрастанию
            if !otherCategories.isEmpty && indexPath.row == 0 {
                // Показываем "Остальное" в начале только если есть больше 6 категорий
                category = AnalyticsConstants.otherCategoriesTitle
                isOtherCategory = true
                isSubCategory = false
            } else if !otherCategories.isEmpty && indexPath.row <= otherCategories.count {
                // Показываем подкатегории "Остального" сразу после него
                category = otherCategories[indexPath.row - 1]
                isOtherCategory = true
                isSubCategory = true
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
                    category = mainCategoriesSorted[index]
                } else {
                    category = mainCategoriesSorted.last ?? sortedByAmount.first ?? ""
                }
                isOtherCategory = false
                isSubCategory = false
            }
        } else {
            // При сортировке по убыванию
            if indexPath.row < mainCategories.count {
                // Показываем основные категории
                category = mainCategories[indexPath.row]
                isOtherCategory = false
                isSubCategory = false
            } else if !otherCategories.isEmpty && indexPath.row == mainCategories.count {
                // Показываем "Остальное" только если есть больше 6 категорий
                category = AnalyticsConstants.otherCategoriesTitle
                isOtherCategory = true
                isSubCategory = false
            } else if !otherCategories.isEmpty {
                // Показываем подкатегории "Остального" сразу после него
                let subCategoryIndex = indexPath.row - mainCategories.count - 1
                if subCategoryIndex < otherCategories.count {
                    category = otherCategories[subCategoryIndex]
                } else {
                    category = otherCategories.last ?? sortedByAmount.first ?? ""
                }
                isOtherCategory = true
                isSubCategory = true
            } else {
                // Если нет дополнительных категорий, показываем следующую основную
                let index = indexPath.row
                if index < sortedByAmount.count {
                    category = sortedByAmount[index]
                } else {
                    category = sortedByAmount.last ?? ""
                }
                isOtherCategory = false
                isSubCategory = false
            }
        }
        
        // Получаем сумму расходов для категории
        let categoryExpense: Decimal
        let percentage: Double?
        
        if category == AnalyticsConstants.otherCategoriesTitle {
            // Для категории "Остальное" суммируем все подкатегории
            categoryExpense = otherCategories.reduce(Decimal(0)) { total, category in
                total + (expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0)
            }
            percentage = totalExpense > 0 ? Double(truncating: categoryExpense as NSDecimalNumber) / Double(truncating: totalExpense as NSDecimalNumber) * 100 : 0
        } else {
            // Для остальных категорий
            categoryExpense = expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
            percentage = isSubCategory ? nil : (totalExpense > 0 ? Double(truncating: categoryExpense as NSDecimalNumber) / Double(truncating: totalExpense as NSDecimalNumber) * 100 : 0)
        }
        
        // Получаем цвет для категории
        let color: UIColor
        if category == AnalyticsConstants.otherCategoriesTitle || isOtherCategory {
            color = .etPurple
        } else {
            color = viewModel.getColorForCategory(category)
        }
        
        // Создаем модель для ячейки
        let cellModel = AnalyticsTableCell.AnalyticsCellModel(
            category: category,
            amount: categoryExpense,
            percentage: percentage,
            color: color,
            currency: viewModel.currency.value,
            isSubCategory: isSubCategory
        )
        
        cell.configure(with: cellModel)
    }
    
    private func updateSortButtonImage() {
        let imageName = viewModel.getIsAscending() ? Asset.Icon.arrowSortUp.rawValue : Asset.Icon.arrowSortDown.rawValue
        sortedCategoryButton.setImage(UIImage(named: imageName)?.withTintColor(.etPrimaryLabel), for: .normal)
    }
    
    // MARK: - Actions
    
    @objc
    private func sortButtonTapped() {
        viewModel.toggleSortOrder()
        updateSortButtonImage()
        reloadTable()
    }
    
    @objc
    private func dayButtonTapped() {
        viewModel.setSelectedDateRange(nil)
        setupFilterButtonState(for: dayButton, with: .day)
        updateDateLabel()
    }
    
    @objc
    private func weekButtonTapped() {
        viewModel.setSelectedDateRange(nil)
        setupFilterButtonState(for: weekButton, with: .week)
        updateDateLabel()
    }
    
    @objc
    private func monthButtonTapped() {
        viewModel.setSelectedDateRange(nil)
        setupFilterButtonState(for: monthButton, with: .month)
        updateDateLabel()
    }
    
    @objc
    private func yearButtonTapped() {
        viewModel.setSelectedDateRange(nil)
        setupFilterButtonState(for: yearButton, with: .year)
        updateDateLabel()
    }
    
    @objc
    private func calendarButtonTapped() {
        DateRangeCalendarView.show(in: self, delegate: self)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AnalyticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedCategories = viewModel.getSortedCategories()
        let expensesByCategory = viewModel.getExpensesByCategory()
        
        // Сортируем категории по сумме расходов (от большей к меньшей)
        let sortedByAmount = sortedCategories.sorted { category1, category2 in
            let amount1 = expensesByCategory[category1]?.reduce(0) { $0 + $1.expense } ?? 0
            let amount2 = expensesByCategory[category2]?.reduce(0) { $0 + $1.expense } ?? 0
            return amount1 > amount2
        }
        
        // Вычисляем суммы расходов для каждой категории
        let categoryAmounts = sortedByAmount.map { category -> (category: String, amount: Decimal) in
            let amount = expensesByCategory[category]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
            return (category: category, amount: amount)
        }
        
        // Распределяем категории на основные и "Остальные"
        var mainCategories: [String] = []
        var otherCategories: [String] = []
        
        if categoryAmounts.count > 6 {
            // Берем первые 5 категорий как основные
            mainCategories = Array(categoryAmounts.prefix(5).map { $0.category })
            
            // Вычисляем сумму расходов для "Остальных"
            let otherAmount = categoryAmounts.dropFirst(5).reduce(Decimal(0)) { $0 + $1.amount }
            
            // Проверяем, нужно ли добавить 6-ю категорию в "Остальные"
            if categoryAmounts.count > 5 {
                let sixthCategoryAmount = categoryAmounts[5].amount
                if otherAmount > sixthCategoryAmount {
                    // Если сумма "Остальных" больше 6-й категории, добавляем её в "Остальные"
                    otherCategories = Array(categoryAmounts.dropFirst(5).map { $0.category })
                } else {
                    // Иначе добавляем 6-ю категорию в основные
                    mainCategories.append(categoryAmounts[5].category)
                    otherCategories = Array(categoryAmounts.dropFirst(6).map { $0.category })
                }
            }
            
            // Проверяем каждую основную категорию (кроме первой)
            for i in 1..<mainCategories.count {
                let currentCategory = mainCategories[i]
                let currentAmount = expensesByCategory[currentCategory]?.reduce(Decimal(0)) { $0 + $1.expense } ?? 0
                
                // Если сумма "Остальных" больше текущей категории
                if otherAmount > currentAmount {
                    // Перемещаем текущую категорию в "Остальные"
                    otherCategories.insert(currentCategory, at: 0)
                    mainCategories.remove(at: i)
                }
            }
        } else {
            // Если категорий 6 или меньше, все они основные
            mainCategories = sortedByAmount
        }
        
        // Если категорий 6 или меньше, показываем все категории
        if otherCategories.isEmpty {
            return min(sortedByAmount.count, 6)
        }
        
        // Иначе показываем все категории, включая "Остальное" и его подкатегории
        return mainCategories.count + 1 + otherCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expenseCategoryTable.dequeueReusableCell(withIdentifier: "ExpenseCategoryCell", for: indexPath) as? AnalyticsTableCell else {
            return UITableViewCell()
        }
        
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AnalyticsConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius = AnalyticsConstants.cornerRadius
        var corners: UIRectCorner = []
        
        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
            if let analyticsCell = cell as? AnalyticsTableCell {
                analyticsCell.hideSeparator()
            }
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
}

// MARK: - DateRangeCalendarViewDelegate

extension AnalyticsViewController: DateRangeCalendarViewDelegate {
    func didSelectDateRange(start: Date, end: Date) {
        viewModel.setTempDateRange((start, end))
        updateDateLabel()
    }
    
    func didConfirmDateRange() {
        if let dateRange = viewModel.getTempDateRange() {
            viewModel.setSelectedDateRange(dateRange)
            resetPeriodButtons()
            filterExpenses()
            updateDateLabel()
            reloadTable()
        }
    }
}
