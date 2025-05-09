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
            if Calendar.current.isDate(dateRange.start, inSameDayAs: dateRange.end) {
                // Если начальная и конечная даты совпадают, показываем только одну дату
                dateLabel.text = dateFormatter.string(from: dateRange.start)
            } else {
                let startDate = dateFormatter.string(from: dateRange.start)
                let endDate = dateFormatter.string(from: dateRange.end)
                dateLabel.text = startDate + " - " + endDate
            }
        } else if let periodType = getSelectedPeriodType() {
            let (startDate, endDate) = viewModel.calculatePeriod(for: viewModel.dayToday.value, periodType: periodType)
            
            if periodType == .day {
                // Для фильтра "День" показываем только сегодняшнюю дату
                dateLabel.text = dateFormatter.string(from: viewModel.dayToday.value)
            } else {
                let startDateString = dateFormatter.string(from: startDate)
                let endDateString = dateFormatter.string(from: endDate)
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
        let chartData = viewModel.getChartData()
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
        // Если кнопка уже выбрана, сбрасываем фильтр
        if button.isSelected {
            button.isSelected = false
            button.backgroundColor = .etCardsToggled
            button.setTitleColor(.etCards, for: .normal)
            viewModel.resetFilters()
            updateUI()
            return
        }
        
        // Сбрасываем состояние всех кнопок
        [dayButton, weekButton, monthButton, yearButton].forEach {
            $0.isSelected = false
            $0.backgroundColor = .etCardsToggled
            $0.setTitleColor(.etCards, for: .normal)
        }
        
        // Устанавливаем новое состояние
        button.isSelected = true
        button.backgroundColor = .etAccent
        button.setTitleColor(.etButtonLabel, for: .normal)
        
        // Обновляем период в ViewModel
        viewModel.setSelectedPeriodType(period)
        updateUI()
    }
    
    private func updateUI() {
        let filteredExpenses = viewModel.getFilteredExpenses()
        updateMoneyLabel(with: viewModel.totalAmount.value)
        updateDateLabel()
        reloadTable()
        
        if viewModel.getExpensesByCategory().isEmpty {
            showEmptyState()
        } else {
            showTableState()
        }
    }
    
    private func filterExpenses() {
        let filteredExpenses = viewModel.getFilteredExpenses()
        viewModel.updateExpensesData(with: filteredExpenses)
        updateUI()
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
        viewModel.resetFilters()
        updateUI()
    }
    
    private func configureCell(_ cell: AnalyticsTableCell, at indexPath: IndexPath) {
        let expensesByCategory = viewModel.getExpensesByCategory()
        let categories = Array(expensesByCategory.keys).sorted()
        let category = categories[indexPath.section]
        let isSubCategory = indexPath.section == categories.count - 1 && category == AnalyticsConstants.otherCategoriesTitle
        
        let cellModel = viewModel.getCellModel(
            for: category,
            expensesByCategory: expensesByCategory,
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
        setupFilterButtonState(for: dayButton, with: .day)
    }
    
    @objc
    private func weekButtonTapped() {
        setupFilterButtonState(for: weekButton, with: .week)
    }
    
    @objc
    private func monthButtonTapped() {
        setupFilterButtonState(for: monthButton, with: .month)
    }
    
    @objc
    private func yearButtonTapped() {
        setupFilterButtonState(for: yearButton, with: .year)
    }
    
    @objc
    private func calendarButtonTapped() {
        // Убираем сброс периода при открытии календаря
        DateRangeCalendarView.show(in: self, delegate: self)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AnalyticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expenseCategoryTable.dequeueReusableCell(withIdentifier: "ExpenseCategoryCell", for: indexPath) as? AnalyticsTableCell else {
            return UITableViewCell()
        }
        
        let (category, isSubCategory) = viewModel.getCategoryForRow(at: indexPath)
        let expensesByCategory = viewModel.getExpensesByCategory()
        
        let cellModel = viewModel.getCellModel(
            for: category,
            expensesByCategory: expensesByCategory,
            isSubCategory: isSubCategory
        )
        
        cell.configure(with: cellModel)
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
        // Только обновляем временный диапазон, не меняя основной
        viewModel.setTempDateRange((start, end))
        updateDateLabel()
    }
    
    func didConfirmDateRange() {
        if let dateRange = viewModel.getTempDateRange() {
            // Применяем фильтр только при подтверждении
            viewModel.setSelectedDateRange(dateRange)
            updateUI()
        }
    }
    
    func didCancelDateRange() {
        // При отмене возвращаемся к предыдущему состоянию
        viewModel.setTempDateRange(nil)
        updateDateLabel()
    }
}
