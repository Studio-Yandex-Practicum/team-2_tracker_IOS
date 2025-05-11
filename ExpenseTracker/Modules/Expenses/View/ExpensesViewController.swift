import UIKit
import CoreData

final class ExpensesViewController: UIViewController {
    
    weak var coordinator: ExpensesCoordinator?
    
    private var viewModel: ExpensesViewModel
    private var totalAmount: Decimal = 0
    private var currency = Currency.ruble.rawValue
    private var dayToday = Date(timeIntervalSinceNow: 0)
    
    private var expensesByDate: [Date: [ExpenseModel]] = [:]
    private var selectedCategories: Set<String>?
    private var selectedDateRange: (start: Date, end: Date)?
    private var tempDateRange: (start: Date, end: Date)?
    
    private var selectedCategory: CategoryMain?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    // MARK: - UI components
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textColor = UIColor.etPrimaryLabel
        dateLabel.textAlignment = .center
        dateLabel.font = AppTextStyle.h2.font
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: Asset.Icon.btnAdd2.rawValue), for: .normal)
        button.addTarget(self, action: #selector(addExpense), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private let expenseMoneyTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .etBackground
        tableView.sectionHeaderTopPadding = 0
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var labelMoney: UILabel = {
        let labelMoney = UILabel()
        labelMoney.text = String(totalAmount.formatted()) + " " + currency
        labelMoney.textColor = .etPrimaryLabel
        labelMoney.font = AppTextStyle.numbers.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        return labelMoney
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
    
    private lazy var categoryButton: FiltersButton = {
        let categoryButton = FiltersButton(title: "Категории", image: (UIImage(named: Asset.Icon.filters.rawValue)?.withTintColor(.etPrimaryLabel))!)
        categoryButton.addTarget(self, action: #selector(showCategoryFilters), for: .touchUpInside)
        return categoryButton
    }()
    
    private let noExpensesLabel: UILabel = {
        let noExpensesLabel = UILabel()
        noExpensesLabel.text = "За этот период нет трат"
        noExpensesLabel.textColor = .etPrimaryLabel
        noExpensesLabel.font = AppTextStyle.h2.font
        noExpensesLabel.textAlignment = .center
        noExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        return noExpensesLabel
    }()
    
    private let addExpensesLabel: UILabel = {
        let addExpensesLabel = UILabel()
        addExpensesLabel.text = "Добавьте расход или измените параметры фильтра."
        addExpensesLabel.textColor = .etPrimaryLabel
        addExpensesLabel.font = AppTextStyle.body.font
        addExpensesLabel.numberOfLines = 2
        addExpensesLabel.textAlignment = .center
        addExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        return addExpensesLabel
    }()
    
    // MARK: - Initialization
    
    init() {
        let context = CoreDataStackManager.shared.context
        self.viewModel = ExpensesViewModel(context: context)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .etBackground
        
        // Настраиваем обработчики изменений
        viewModel.onExpensesDidChange = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onError = { [weak self] error in
            // Показываем ошибку пользователю
            let alert = UIAlertController(
                title: "Ошибка",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        self.expenseMoneyTable.register(ExpensesTableCell.self, forCellReuseIdentifier: "ExpensesTableCell")
        addSubviews()
        setupLayout()
        
        // Загружаем расходы
        loadExpenses(for: dayToday, periodType: nil)
        
        // Проверяем наличие расходов и показываем соответствующее состояние
        if expensesByDate.isEmpty {
            showEmptyState()
        } else {
            showTableState()
        }
    }
    
    private func updateUI() {
        expensesByDate = viewModel.getAllExpensesByDate()
        totalAmount = viewModel.totalAmount
        updateMoneyLabel()
        
        if expensesByDate.isEmpty {
            showEmptyState()
        } else {
            showTableState()
        }
        
        expenseMoneyTable.reloadData()
    }
    
    private func setupFilterButtonState(for button: UIButton, with period: PeriodType) {
        button.isSelected.toggle()
        [dayButton, weekButton, monthButton, yearButton].forEach {
            $0.backgroundColor = button == $0 && $0.isSelected ? .etAccent : .etCardsToggled
            let titleColor = button == $0 && $0.isSelected ? UIColor.etButtonLabel : UIColor.etCards
            $0.setTitleColor(titleColor, for: .normal)
            
            if button != $0 {
                $0.isSelected = false
            }
            setFilters(for: button, with: period)
        }
    }
    
    private func setFilters(for button: UIButton, with period: PeriodType) {
        let selectedDate = dayToday
        let period = button.isSelected ? period : nil
        filterExpenses()
    }
    
    @objc
    private func addExpense() {
//        let addExpenseVC = NewCategoryViewController()
//        addExpenseVC.delegate = self
        coordinator?.showAddExpenseFlow(with: self)
    }
    
    // Пример вызова для кнопок
    @objc
    private func dayButtonTapped() {
        selectedDateRange = nil
        setupFilterButtonState(for: dayButton, with: .day)
        setupLayout()
    }
    
    @objc
    private func weekButtonTapped() {
        selectedDateRange = nil
        setupFilterButtonState(for: weekButton, with: .week)
        setupLayout()
    }
    
    @objc
    private func monthButtonTapped() {
        selectedDateRange = nil
        setupFilterButtonState(for: monthButton, with: .month)
        setupLayout()
    }
    
    @objc
    private func yearButtonTapped() {
        selectedDateRange = nil
        setupFilterButtonState(for: yearButton, with: .year)
        setupLayout()
    }
    
    @objc
    private func showCategoryFilters() {
        coordinator?.showCategoryFiltersFlow()
    }
    
    private func filterExpenses() {
        var filteredExpenses: [ExpenseModel]
        
        // Получаем расходы в зависимости от выбранного периода
        if let dateRange = selectedDateRange {
            let startOfDay = Calendar.current.startOfDay(for: dateRange.start)
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: dateRange.end) ?? dateRange.end
            
            let expensesByDate = viewModel.getExpensesForPeriod(startDate: startOfDay, endDate: endOfDay)
            filteredExpenses = expensesByDate.values.flatMap { $0 }
            calendarButton.setImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etAccent), for: .normal)
        } else if let periodType = getSelectedPeriodType() {
            let (startDate, endDate) = calculatePeriod(for: dayToday, periodType: periodType)
            let startOfDay = Calendar.current.startOfDay(for: startDate)
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
            
            let expensesByDate = viewModel.getExpensesForPeriod(startDate: startOfDay, endDate: endOfDay)
            filteredExpenses = expensesByDate.values.flatMap { $0 }
            calendarButton.setImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etCards), for: .normal)
        } else {
            filteredExpenses = viewModel.getAllExpenses()
            calendarButton.setImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etCards), for: .normal)
        }
        
        // Фильтрация по категориям
        if let selectedCategories = selectedCategories, !selectedCategories.isEmpty {
            filteredExpenses = filteredExpenses.filter { expense in
                guard
                    let expenseCategory = expense.category,
                    let categoryName = expenseCategory.name
                else { return false }
                return selectedCategories.contains(categoryName)
                 
            }
        }
        
        // Группируем расходы по датам
        expensesByDate = Dictionary(grouping: filteredExpenses) { expense in
            if let date = expense.date {
                return Calendar.current.startOfDay(for: date)
            }
            return Date()
        }
        
        // Обновляем общую сумму
        totalAmount = filteredExpenses.reduce(0, { $0 + ($1.amount?.decimalValue ?? 0) })
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = ","
        
        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
            // Если сумма равна 0, показываем только "0"
            if totalAmount == 0 {
                labelMoney.text = "0 " + currency
            } else {
                labelMoney.text = formattedAmount + " " + currency
            }
        }
        
        // Обновляем отображение даты
        if let dateRange = selectedDateRange {
            dateLabel.text = dateFormatter.string(from: dateRange.start) + " - " + dateFormatter.string(from: dateRange.end)
        } else if let periodType = getSelectedPeriodType() {
            let (startDate, endDate) = calculatePeriod(for: dayToday, periodType: periodType)
            let textForCurrentDate = dateFormatter.string(from: startDate)
            let startOfCurrentDay = Calendar.current.startOfDay(for: dayToday)
            dateLabel.text = startOfCurrentDay == startDate ? textForCurrentDate : dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
        } else {
            dateLabel.text = "Расходы"
        }
        
        // Показываем таблицу или пустое состояние
        if filteredExpenses.isEmpty {
            showEmptyState()
        } else {
            showTableState()
        }
    }
    
    private func showEmptyState() {
        if expenseMoneyTable.superview != nil {
            expenseMoneyTable.removeFromSuperview()
        }
        if noExpensesLabel.superview == nil {
            view.addSubview(noExpensesLabel)
            view.addSubview(addExpensesLabel)
            setupEmptyStateConstraints()
        }
    }
    
    private func showTableState() {
        if noExpensesLabel.superview != nil {
            noExpensesLabel.removeFromSuperview()
            addExpensesLabel.removeFromSuperview()
        }
        if expenseMoneyTable.superview == nil {
            view.addSubview(expenseMoneyTable)
            setupTableConstraints()
        }
        expenseMoneyTable.reloadData()
    }
    
    private func setupEmptyStateConstraints() {
        noExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        addExpensesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noExpensesLabel.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 96),
            noExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            noExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            addExpensesLabel.topAnchor.constraint(equalTo: noExpensesLabel.bottomAnchor, constant: 8),
            addExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            addExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func setupTableConstraints() {
        expenseMoneyTable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            expenseMoneyTable.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 12),
            expenseMoneyTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            expenseMoneyTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            expenseMoneyTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func getSelectedPeriodType() -> PeriodType? {
        if dayButton.isSelected { return .day }
        if weekButton.isSelected { return .week }
        if monthButton.isSelected { return .month }
        if yearButton.isSelected { return .year }
        return nil
    }
    
    func addSubviews() {
        expenseMoneyTable.delegate = self
        expenseMoneyTable.dataSource = self
        
        view.addSubview(dateLabel)
        view.addSubview(addCategoryButton)
        view.addSubview(labelMoney)
        view.addSubview(calendarButton)
        view.addSubview(calendarStack)
        view.addSubview(categoryButton)
        
        calendarStack.addArrangedSubview(dayButton)
        calendarStack.addArrangedSubview(weekButton)
        calendarStack.addArrangedSubview(monthButton)
        calendarStack.addArrangedSubview(yearButton)
    }
    
    func setupLayout() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let constraints = [
            addCategoryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateLabel.centerYAnchor.constraint(equalTo: addCategoryButton.centerYAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            labelMoney.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            labelMoney.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            calendarButton.topAnchor.constraint(equalTo: labelMoney.bottomAnchor, constant: 17),
            calendarButton.heightAnchor.constraint(equalToConstant: 24),
            calendarButton.widthAnchor.constraint(equalToConstant: 24),
            calendarButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            calendarStack.topAnchor.constraint(equalTo: labelMoney.bottomAnchor, constant: 16),
            calendarStack.heightAnchor.constraint(equalToConstant: 28),
            calendarStack.leadingAnchor.constraint(equalTo: calendarButton.trailingAnchor, constant: 10),
            calendarStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: calendarButton.bottomAnchor, constant: 18),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func loadExpenses(for selectedDate: Date, periodType: PeriodType?) {
        if let periodType = periodType {
            let (startDate, endDate) = calculatePeriod(for: selectedDate, periodType: periodType)
            expensesByDate = viewModel.getExpensesForPeriod(startDate: startDate, endDate: endDate)
            
            // Подсчитываем общую сумму для выбранного периода
            let allExpenses = expensesByDate.values.flatMap { $0 }
            totalAmount = allExpenses.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.groupingSeparator = " "
            numberFormatter.decimalSeparator = ","
            
            if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
                // Если сумма равна 0, показываем только "0"
                if totalAmount == 0 {
                    labelMoney.text = "0 " + currency
                } else {
                    labelMoney.text = formattedAmount + " " + currency
                }
            }
            
            let textForCurrentDate = dateFormatter.string(from: startDate)
            let startOfCurrentDay = Calendar.current.startOfDay(for: selectedDate)
            dateLabel.text = startOfCurrentDay == startDate ? textForCurrentDate : dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
            dateLabel.applyTextStyle(.h2, textStyle: .caption2)
        } else {
            expensesByDate = viewModel.getAllExpensesByDate()
            
            // Подсчитываем общую сумму для всех расходов
            let allExpenses = expensesByDate.values.flatMap { $0 }
            totalAmount = allExpenses.reduce(0) { $0 + ($1.amount?.decimalValue ?? 0) }
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.groupingSeparator = " "
            numberFormatter.decimalSeparator = ","
            
            if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
                // Если сумма равна 0, показываем только "0"
                if totalAmount == 0 {
                    labelMoney.text = "0 " + currency
                } else {
                    labelMoney.text = formattedAmount + " " + currency
                }
            }
            
            dateLabel.text = "Расходы"
            dateLabel.applyTextStyle(.h2, textStyle: .caption2)
        }
        expenseMoneyTable.reloadData()
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
            let range = currentCalendar.range(of: .day, in: .month, for: selectedDate)!
            startDate = currentCalendar.date(byAdding: .day, value: -range.count - 1, to: endDate)!
        case .year:
            endDate = selectedDate
            // Находим год, отнимая от текущего дня год
            startDate = currentCalendar.date(byAdding: .year, value: -1, to: endDate)!
        }
        return (startDate, endDate)
    }
    
    private func updateMoneyLabel() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = ","
        
        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
            // Если сумма равна 0, показываем только "0"
            if totalAmount == 0 {
                labelMoney.text = "0 " + currency
            } else {
                labelMoney.text = formattedAmount + " " + currency
            }
        }
    }
}

// MARK: - TableView Functhion

extension ExpensesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return expensesByDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateKeys = Array(expensesByDate.keys)
        let dateKey = dateKeys.sorted(by: >)
        return expensesByDate[dateKey[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expenseMoneyTable.dequeueReusableCell(withIdentifier: "ExpensesTableCell", for: indexPath) as? ExpensesTableCell else {
            return UITableViewCell()
        }
        
        let dateKeys = Array(expensesByDate.keys)
        let dateKey = dateKeys.sorted(by: >)
        
        if let expenses = expensesByDate[dateKey[indexPath.section]] {
            let sortedExpenses = expenses.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
            let expense = sortedExpenses[indexPath.row]
            
            // Конвертируем ExpenseModel в Expense для ячейки
            let expenseForCell = Expense(
                id: expense.id ?? UUID(),
                expense: expense.amount?.decimalValue ?? 0,
                category: Category(id: expense.category?.id ?? UUID(), name: expense.category?.name ?? "", icon: Asset.Icon(rawValue: expense.category?.icon ?? "") ?? .customCat),
                date: expense.date ?? Date(),
                note: expense.note ?? ""
            )
            
            cell.configure(with: expenseForCell)
            
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.hideSeparator()
            } else {
                cell.showSeparator()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: nil) {
            [weak self] _,
            _,
            completion in
            let alert = UIAlertController(title: "Уверены, что хотите удалить?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Выход", style: .cancel, handler: nil))
            alert.addAction(
                UIAlertAction(title: "ОК", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    
                    // Получаем расход для удаления
                    let dateKeys = Array(self.expensesByDate.keys).sorted(by: >)
                    if let expenses = self.expensesByDate[dateKeys[indexPath.section]] {
                        let sortedExpenses = expenses.sorted {
                            if let firstDate = $0.date as Date?,
                               let secondDate = $1.date as Date? {
                                return firstDate > secondDate
                            }
                            return false
                        }
                        
                        let expense = sortedExpenses[indexPath.row]
                        // Удаляем расход из модели данных
                        
                        let categoryModel = Category(
                            id: expense.category?.id ?? UUID(),
                            name: expense.category?.name ?? "",
                            icon: Asset.Icon(
                                rawValue: expense.category?.icon ?? ""
                            ) ?? .customCat
                        )
                        
                        let expenseModel = Expense(
                            id: expense.id ?? UUID(),
                            expense: expense.amount?.decimalValue ?? 0,
                            category: categoryModel,
                            date: expense.date ?? Date(),
                            note: expense.note ?? ""
                        )
                        self.viewModel.removeExpense(expenseModel)
                        
                        // Обновляем данные
                        self.expensesByDate = self.viewModel.getAllExpensesByDate()
                        
                        // Обновляем общую сумму
                        self.totalAmount = self.viewModel.totalAmount
                        
                        // Обновляем UI
                        self.updateMoneyLabel()
                        
                        // Проверяем, нужно ли показать пустое состояние
                        if self.expensesByDate.isEmpty {
                            self.showEmptyState()
                        } else {
                            // Обновляем таблицу
                            tableView.reloadData()
                        }
                    }
                })
            self?.present(alert, animated: true)
            
            completion(true)
        }
        delete.image = UIImage(named: "delete")?.withTintColor(.etButtonLabel)
        delete.backgroundColor = UIColor.etbRed
        
        let addExpense = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            
            // Получаем расход для редактирования
            let dateKeys = Array(self.expensesByDate.keys).sorted(by: >)
            if let expenses = self.expensesByDate[dateKeys[indexPath.section]] {
                let sortedExpenses = expenses.sorted {
                    if let firstDate = $0.date as Date?,
                       let secondDate = $1.date as Date? {
                        return firstDate > secondDate
                    }
                    return false
                }
                let expense = sortedExpenses[indexPath.row]
                
                let categoryModel = Category(
                    id: expense.category?.id ?? UUID(),
                    name: expense.category?.name ?? "",
                    icon: Asset.Icon(
                        rawValue: expense.category?.icon ?? ""
                    ) ?? .customCat
                )
                
                let expenseModel = Expense(
                    id: expense.id ?? UUID(),
                    expense: expense.amount?.decimalValue ?? 0,
                    category: categoryModel,
                    date: expense.date ?? Date(),
                    note: expense.note ?? ""
                )
                coordinator?.showChangeExpenseFlow(with: self, expense: expenseModel)
            }
            completion(true)
        }
        
        addExpense.image = UIImage(named: "edit")?.withTintColor(.etButtonLabel)
        addExpense.backgroundColor = .etOrange
        
        return UISwipeActionsConfiguration(actions: [delete, addExpense])
    }
    
    //
    
    // Закругление углов секции таблицы
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius = 12
        var corners: UIRectCorner = []
        
        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
    
    // MARK: - Headers
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Формат отображения даты
        
        let headerView = ExpensesTableHeaders()
        let dateKeys = Array(expensesByDate.keys)
        let dateKey = dateKeys.sorted(by: >)
        headerView.configure(title: dateKey[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.tintColor = .etBackground
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        16
    }
}

// MARK: - DateRangeCalendarViewDelegate

extension ExpensesViewController: DateRangeCalendarViewDelegate {
    
    func didSelectDateRange(start: Date, end: Date) {
        // Сохраняем временный диапазон дат
        tempDateRange = (start, end)
    }
    
    func didConfirmDateRange() {
        // Применяем фильтр только при нажатии ОК
        if let dateRange = tempDateRange {
            selectedDateRange = dateRange
            // Сбрасываем выбранные кнопки периода
            [dayButton, weekButton, monthButton, yearButton].forEach {
                $0.isSelected = false
                $0.backgroundColor = .etCardsToggled
                $0.setTitleColor(.etCards, for: .normal)
            }
            filterExpenses()
        }
    }

    @objc
    private func calendarButtonTapped() {
        DateRangeCalendarView.show(in: self, delegate: self)
    }
}

extension ExpensesViewController: ChangeExpensesDelegate {
    
    func createExpense(_ newExpense: Expense) {
        viewModel.addExpense(
            expense: newExpense.expense,
            category: CategoryMain(title: newExpense.category.name, icon: newExpense.category.icon),
            date: newExpense.date
        )
        loadExpenses(for: dayToday, periodType: nil)
    }
    
    func updateExpense(_ updatedExpense: Expense) {
        // Обновляем расход в модели данных
        viewModel.updateExpense(updatedExpense)
        
        // Обновляем данные
        expensesByDate = viewModel.getAllExpensesByDate()
        
        // Обновляем общую сумму
        totalAmount = viewModel.totalAmount
        
        // Обновляем UI
        updateMoneyLabel()
        
        // Обновляем таблицу
        expenseMoneyTable.reloadData()
    }
}

extension ExpensesViewController: CategorySelectionDelegate {
    
    func didSelectCategories(_ categories: Set<String>) {
        selectedCategories = categories
        filterExpenses()
    }
    
    func didSelectCategoryForExpense(_ categories: CategoryMain) {
        selectedCategory = categories
        categoryButton.setTitle(categories.title, for: .normal)
        categoryButton.setImage(UIImage(named: categories.icon.rawValue), for: .normal)
    }
}
