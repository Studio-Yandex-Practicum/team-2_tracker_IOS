import UIKit
import SwiftUICore

final class AnalyticsViewController: UIViewController {
    
    weak var coordinator: AnalyticsCoordinator?
    
    var viewModel = ExpensesViewModel()
    var totalAmount: Decimal = 12345
    var currency = Currency.ruble.rawValue
    var dayToday = Date(timeIntervalSinceNow: 0)
    var colorCategory = [UIColor.etbRed, UIColor.etOrange, UIColor.etGreen, UIColor.etBlue,
                         UIColor.etPurple, UIColor.etPink, UIColor.etYellow, UIColor.etGrayBlue]
    
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
        dateLabel.text = "Пример категорий"
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    
    private lazy var labelMoney: UILabel = {
        let labelMoney = UILabel()
        labelMoney.textColor = .etPrimaryLabel
        labelMoney.font = AppTextStyle.h1.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = ","
        
        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
            labelMoney.text = formattedAmount + " " + currency
        }
        
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var sortedCategoryButton: FiltersButton = {
        let categoryButton = FiltersButton(title: "Сортировать", image: (UIImage(named: Asset.Icon.arrowSortDown.rawValue)?.withTintColor(.etPrimaryLabel))!)
        categoryButton.titleLabel?.applyTextStyle(.body, textStyle: .body)
  //      categoryButton.addTarget(self, action: #selector(showCategoryFilters), for: .touchUpInside)
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
    
    private let calendarButton: CalendarButton = {
        let calendarButton = CalendarButton(backgroundColor: .etBackground)
        return calendarButton
    }()
    
    private lazy var dayButton: TimeButton = {
        let dayButton = TimeButton(title: ButtonTitel.day.rawValue)
        //     dayButton.addTarget(self, action: #selector(dayButtonTapped), for: .touchUpInside)
        return dayButton
    }()
    
    private lazy var weekButton: TimeButton = {
        let weekButton = TimeButton(title: ButtonTitel.week.rawValue)
        //     weekButton.addTarget(self, action: #selector(weekButtonTapped), for: .touchUpInside)
        return weekButton
    }()
    
    private lazy var monthButton: TimeButton = {
        let monthButton = TimeButton(title: ButtonTitel.month.rawValue)
        //     monthButton.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
        return monthButton
    }()
    
    private lazy var yearButton: TimeButton = {
        let yearButton = TimeButton(title: ButtonTitel.year.rawValue)
        //     yearButton.addTarget(self, action: #selector(yearButtonTapped), for: .touchUpInside)
        return yearButton
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
        
        // Обновляем общую сумму
        totalAmount = filteredExpenses.reduce(0, { $0 + $1.expense })
        
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//        numberFormatter.minimumFractionDigits = 2
//        numberFormatter.maximumFractionDigits = 2
//        numberFormatter.groupingSeparator = " "
//        numberFormatter.decimalSeparator = ","
//        
//        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: totalAmount)) {
//            labelMoney.text = formattedAmount + " " + currency
//        }
        
        // Обновляем отображение даты
        if let periodType = getSelectedPeriodType() {
            let (startDate, endDate) = calculatePeriod(for: dayToday, periodType: periodType)
            let textForCurrentDate = dateFormatter.string(from: startDate)
            let startOfCurrentDay = Calendar.current.startOfDay(for: dayToday)
            dateLabel.text = startOfCurrentDay == startDate ? textForCurrentDate : dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
        } else {
            dateLabel.text = "Расходы"
        }
        
        expenseCategoryTable.reloadData()
    }
    
    private func getSelectedPeriodType() -> PeriodType? {
        if dayButton.isSelected { return .day }
        if weekButton.isSelected { return .week }
        if monthButton.isSelected { return .month }
        if yearButton.isSelected { return .year }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.expenseCategoryTable.register(AnalyticsTableCell.self, forCellReuseIdentifier: "ExpenseCategoryCell")
        view.backgroundColor = .etBackground
       
        addSubviews()
        setupLayout()
        setupDonutChart()
    }
    
    func addSubviews() {
        expenseCategoryTable.delegate = self
        expenseCategoryTable.dataSource = self
        
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
    }

    func setupLayout() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        var constraints = [
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
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
        
        if totalAmount == 0 {
            view.addSubview(noExpensesLabel)
            view.addSubview(addExpensesLabel)
            
            constraints += [
                noExpensesLabel.topAnchor.constraint(equalTo: sortedCategoryButton.bottomAnchor, constant: 96),
                noExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                noExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                
                addExpensesLabel.topAnchor.constraint(equalTo: noExpensesLabel.bottomAnchor, constant: 8),
                addExpensesLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                addExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)]
        } else {
            view.addSubview(expenseCategoryTable)
            constraints += [
                expenseCategoryTable.topAnchor.constraint(equalTo: sortedCategoryButton.bottomAnchor, constant: 12),
                expenseCategoryTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                expenseCategoryTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                expenseCategoryTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)]
        }
        NSLayoutConstraint.activate(constraints)
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
    
    private func setupDonutChart() {
        let data: [(value: Double, color: UIColor)] = [
            (1, .etbRed),
            (1, .etGrayBlue),
            (1, .etGreen),
            (1, .etBlue),
            (1, .etYellow),
            (1, .etPurple),
            (1, .etbRed)
        ]
        donutChartView.configure(with: data, overlapAngle: 8)
    }
}

// MARK: - TableView Functhion
    extension AnalyticsViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            8
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let cell = expenseCategoryTable .dequeueReusableCell(withIdentifier: "ExpenseCategoryCell", for: indexPath) as? AnalyticsTableCell {
                cell.contentView.backgroundColor = .etBackground
                cell.separatorInset = UIEdgeInsets.zero
                cell.selectionStyle = .none
                cell.translatesAutoresizingMaskIntoConstraints = true
                cell.expenceView.backgroundColor = colorCategory[indexPath.row]
                
//                            let dateKeys = Array(expensesByDate.keys)
//                            let dateKey = dateKeys.sorted(by: >)
//                            if let expense = expensesByDate[dateKey[indexPath.section]]?[indexPath.row] {
//                                cell.expenceView.backgroundColor = colorCategory[indexPath.row]
//                                cell.categoryMoney.text = expense.category
//                                let amount = expense.formattedAsRuble
//                                cell.labelMoneyCash.text = amount
//                                cell.percentMoney.text = "1000" + " %"
//                            }
                return cell
            } else {
                // Обработка случая, когда не удалось произвести преобразование
                print("Failed to dequeue a cell of type ExpenseCategoryCell")
                return UITableViewCell()
            }
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
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
        
        
    }
    


