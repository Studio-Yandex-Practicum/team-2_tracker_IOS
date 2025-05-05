import UIKit

final class ExpensesViewController: UIViewController {
    
    weak var coordinator: ExpensesCoordinator?
    
  //  var expenses: [Expense] = expensesMockData
    var viewModel = ExpensesViewModel()
    var totalAmount: Decimal = 12345
    var currency = Currency.ruble.rawValue
    var dayToday = Date(timeIntervalSinceNow: 0)
    
    private var expensesByDate: [Date: [Expense]] = [:]
    private var selectedCategories: Set<String>?
    
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
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: Asset.Icon.btnAdd2.rawValue), for: .normal)
        button.addTarget(self, action: #selector(addExpense), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.widthAnchor.constraint(equalToConstant: 56).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let expenseMoneyTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .etBackground
        tableView.sectionHeaderTopPadding = 0
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = .zero
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
    
    private let calendarButton: CalendarButton = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .etBackground
        
        self.expenseMoneyTable.register(ExpensesTableCell.self, forCellReuseIdentifier: "ExpensesTableCell")
        addSubviews()
        setupLayout()
        loadExpenses(for: dayToday, periodType: nil)
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
        loadExpenses(for: selectedDate, periodType: period)
    }
    
    @objc
    private func addExpense() {
        coordinator?.showAddExpenseFlow()
    }
    
    // Пример вызова для кнопок
    @objc
    private func dayButtonTapped() {
        setupFilterButtonState(for: dayButton, with: .day)
    }
    
    @objc
    private func weekButtonTapped() {
        setupFilterButtonState(for: weekButton, with: .week)
    }
    
    @objc
    private  func monthButtonTapped() {
        setupFilterButtonState(for: monthButton, with: .month)
    }
    
    @objc
    private func yearButtonTapped() {
        setupFilterButtonState(for: yearButton, with: .year)
    }
    
    @objc
    private func showCategoryFilters() {
        coordinator?.showCategoryFiltersFlow()
    }
    
    private func filterExpenses() {
        var filteredExpenses: [Expense]
        
        // Получаем расходы в зависимости от выбранного периода
        if let periodType = getSelectedPeriodType() {
            let (startDate, endDate) = calculatePeriod(for: dayToday, periodType: periodType)
            let expensesByDate = viewModel.getExpensesForPeriod(startDate: startDate, endDate: endDate)
            filteredExpenses = expensesByDate.values.flatMap { $0 }
        } else {
            filteredExpenses = viewModel.getAllExpenses()
        }
        
        // Фильтрация по категориям
        if let selectedCategories = selectedCategories, !selectedCategories.isEmpty {
            filteredExpenses = filteredExpenses.filter { expense in
                selectedCategories.contains(expense.category.description)
            }
        }
        
        // Группируем расходы по датам
        expensesByDate = Dictionary(grouping: filteredExpenses) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        
        // Обновляем общую сумму
        totalAmount = filteredExpenses.reduce(0, { $0 + $1.expense })
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = ","
        
        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
            labelMoney.text = formattedAmount + " " + currency
        }
        
        // Обновляем отображение даты
        if let periodType = getSelectedPeriodType() {
            let (startDate, endDate) = calculatePeriod(for: dayToday, periodType: periodType)
            let textForCurrentDate = dateFormatter.string(from: startDate)
            let startOfCurrentDay = Calendar.current.startOfDay(for: dayToday)
            dateLabel.text = startOfCurrentDay == startDate ? textForCurrentDate : dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
        } else {
            dateLabel.text = "Расходы"
        }
        
        expenseMoneyTable.reloadData()
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
        
        var constraints = [
            
            dateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 56),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
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
        
        if totalAmount == 0 {
            view.addSubview(noExpensesLabel)
            view.addSubview(addExpensesLabel)
            
            constraints += [
                noExpensesLabel.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 96),
                noExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                noExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                
                addExpensesLabel.topAnchor.constraint(equalTo: noExpensesLabel.bottomAnchor, constant: 8),
                addExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                addExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
            ]
        } else {
            view.addSubview(expenseMoneyTable)
            constraints += [
                expenseMoneyTable.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 12),
                expenseMoneyTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                expenseMoneyTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                expenseMoneyTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    private func loadExpenses(for selectedDate: Date, periodType: PeriodType?) {
        if let periodType = periodType {
            let (startDate, endDate) = calculatePeriod(for: selectedDate, periodType: periodType)
            expensesByDate = viewModel.getExpensesForPeriod(startDate: startDate, endDate: endDate)
            
            // Подсчитываем общую сумму для выбранного периода
            let allExpenses = expensesByDate.values.flatMap { $0 }
            totalAmount = allExpenses.reduce(0) { $0 + $1.expense }
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.groupingSeparator = " "
            numberFormatter.decimalSeparator = ","
            
            if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
                labelMoney.text = formattedAmount + " " + currency
            }
            
            let textForCurrentDate = dateFormatter.string(from: startDate)
            let startOfCurrentDay = Calendar.current.startOfDay(for: selectedDate)
            dateLabel.text = startOfCurrentDay == startDate ? textForCurrentDate : dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
            dateLabel.applyTextStyle(.h2, textStyle: .caption2)
        } else {
            expensesByDate = viewModel.getAllExpensesByDate()
            
            // Подсчитываем общую сумму для всех расходов
            let allExpenses = expensesByDate.values.flatMap { $0 }
            totalAmount = allExpenses.reduce(0) { $0 + $1.expense }
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.groupingSeparator = " "
            numberFormatter.decimalSeparator = ","
            
            if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
                labelMoney.text = formattedAmount + " " + currency
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
        if let cell = expenseMoneyTable.dequeueReusableCell(withIdentifier: "ExpensesTableCell", for: indexPath) as? ExpensesTableCell {
            cell.contentView.backgroundColor = .etBackground
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = .none
            cell.translatesAutoresizingMaskIntoConstraints = true
    
            let dateKeys = Array(expensesByDate.keys)
            let dateKey = dateKeys.sorted(by: >)
            if let expense = expensesByDate[dateKey[indexPath.section]]?[indexPath.row] {
                cell.categoryMoney.text = expense.category
                let amount = expense.formattedAsRuble
                cell.labelMoneyCash.text = amount
                cell.noteMoney.text = expense.expense.formatted()
            }
            return cell
        } else {
            // Обработка случая, когда не удалось произвести преобразование
            print("Failed to dequeue a cell of type ExpensesTableCell")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            
            let alert = UIAlertController(title: "Уверены, что хотите удалить?", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Выход", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "ОК", style: .default) { _ in
 
                tableView.deleteRows(at: [indexPath], with: .automatic)
               tableView.reloadData()
            })
            self.present(alert, animated: true)
            
            
            completion(true)
        }
        delete.image = UIImage(named: "delete")?.withTintColor(.etButtonLabel)
        delete.backgroundColor = .etbRed
        
        let addExpense = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            
            let changeVC = ChangeExpensesViewController(.change)
            
            self.navigationController?.pushViewController(changeVC, animated: true)
          
            self.navigationController?.setNavigationBarHidden(true, animated: .init())
            changeVC.navigationController?.isNavigationBarHidden = true
       //     self.navigationController?.isNavigationBarHidden.
            print("Кнопка нажита")
            completion(true)
        }
        
        addExpense.image =  UIImage(named: "edit")?.withTintColor(.etButtonLabel)
        addExpense.backgroundColor = .etOrange
        
        return UISwipeActionsConfiguration(actions: [delete, addExpense])
    }
    
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

// MARK: - CategorySelectionDelegate

extension ExpensesViewController: CategorySelectionDelegate {
    
    func didSelectCategories(_ categories: Set<String>) {
        selectedCategories = categories
        filterExpenses()
    }
}

// MARK: - DateRangeCalendarViewDelegate

extension ExpensesViewController: DateRangeCalendarViewDelegate {

    func didSelectDateRange(start: Date, end: Date) {
        // Обработка выбранного диапазона дат
        // TODO: Обновить UI с выбранным диапазоном дат
    }

    @objc private func calendarButtonTapped() {
        DateRangeCalendarView.show(in: self, delegate: self)
    }
}
