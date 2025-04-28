import UIKit

final class ExpensesViewController: UIViewController {
    
    weak var coordinator: ExpensesCoordinator?
    
  //  var expenses: [Expense] = expensesMockData
    var viewModel = ExpensesViewModel()
    var totalAmount: Double = 12345
    var currency = Currency.ruble.rawValue
    var dayToday = Date(timeIntervalSinceNow: 0)
    
    private var expensesByDate: [Date: [Expense]] = [:]

    
  
    
    // MARK: - UI components
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
    
    private let categoryButton: FiltersButton = {
        let categoryButton = FiltersButton(title: "Категории", image: (UIImage(named: Asset.Icon.filters.rawValue)?.withTintColor(.etPrimaryLabel))!)
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
        
        setupNavigation()
        addSubviews()
        setupLayout()
        loadExpenses(for: dayToday, periodType: .month)
    }
    
    func setupNavigation() {
        // Устанавливаем атрибуты для заголовка
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AppTextStyle.h2.font,
            .foregroundColor: UIColor.etPrimaryLabel
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: Asset.Icon.btnAdd2.rawValue), style: .done, target: self, action: #selector(addExpense))
    }
    
    
    @objc private func addExpense() {
        let addVC = ChangeExpensesViewController(.add)
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    // Пример вызова для кнопок
    @objc private  func dayButtonTapped() {
        dayButton.backgroundColor = .etAccent
        dayButton.setTitleColor(.etButtonLabel, for: .normal)
        weekButton.backgroundColor = .etCardsToggled
        monthButton.backgroundColor = .etCardsToggled
        yearButton.backgroundColor = .etCardsToggled
        weekButton.setTitleColor(.etCards, for: .normal)
        monthButton.setTitleColor(.etCards, for: .normal)
        yearButton.setTitleColor(.etCards, for: .normal)
        let selectedDate = dayToday
       
        // или любая другая дата, которую вы хотите использовать
        loadExpenses(for: selectedDate, periodType: .day)
     //   expenseMoneyTable.reloadData()
     //   expenseMoneyTable.endUpdates()
        
    }
    
    @objc private func weekButtonTapped() {
        weekButton.backgroundColor = .etAccent
        weekButton.setTitleColor(.etButtonLabel, for: .normal)
        dayButton.backgroundColor = .etCardsToggled
        monthButton.backgroundColor = .etCardsToggled
        yearButton.backgroundColor = .etCardsToggled
        dayButton.setTitleColor(.etCards, for: .normal)
        monthButton.setTitleColor(.etCards, for: .normal)
        yearButton.setTitleColor(.etCards, for: .normal)
        let selectedDate = dayToday
        loadExpenses(for: selectedDate, periodType: .week)
        expenseMoneyTable.reloadData()
        expenseMoneyTable.endUpdates()
        
    }
    
    @objc private  func monthButtonTapped() {
        monthButton.backgroundColor = .etAccent
        monthButton.setTitleColor(.etButtonLabel, for: .normal)
        weekButton.backgroundColor = .etCardsToggled
        dayButton.backgroundColor = .etCardsToggled
        yearButton.backgroundColor = .etCardsToggled
        weekButton.setTitleColor(.etCards, for: .normal)
        dayButton.setTitleColor(.etCards, for: .normal)
        yearButton.setTitleColor(.etCards, for: .normal)
        let selectedDate = dayToday
        loadExpenses(for: selectedDate, periodType: .month)
        expenseMoneyTable.reloadData()
    }
    
    @objc private  func yearButtonTapped() {
        yearButton.backgroundColor = .etAccent
        yearButton.setTitleColor(.etButtonLabel, for: .normal)
        dayButton.backgroundColor = .etCardsToggled
        weekButton.backgroundColor = .etCardsToggled
        monthButton.backgroundColor = .etCardsToggled
        dayButton.setTitleColor(.etCards, for: .normal)
        weekButton.setTitleColor(.etCards, for: .normal)
        monthButton.setTitleColor(.etCards, for: .normal)
        let selectedDate = dayToday
        loadExpenses(for: selectedDate, periodType: .year)
        expenseMoneyTable.reloadData()
    }
    
    
    func addSubviews() {
        expenseMoneyTable.delegate = self
        expenseMoneyTable.dataSource = self
        
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
        var constraints = [
            
            labelMoney.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            labelMoney.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            calendarButton.topAnchor.constraint(equalTo: labelMoney.bottomAnchor, constant: 16),
            calendarButton.heightAnchor.constraint(equalToConstant: 28),
            calendarButton.widthAnchor.constraint(equalToConstant: 28),
            calendarButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            calendarStack.topAnchor.constraint(equalTo: labelMoney.bottomAnchor, constant: 16),
            calendarStack.heightAnchor.constraint(equalToConstant: 28),
            calendarStack.leadingAnchor.constraint(equalTo: calendarButton.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            calendarStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: calendarButton.bottomAnchor, constant: 22),
            categoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
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
                addExpensesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24) ]
            
        } else {
            view.addSubview(expenseMoneyTable)
            constraints += [
                expenseMoneyTable.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 12),
                expenseMoneyTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                expenseMoneyTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                expenseMoneyTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor) ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    private func loadExpenses(for selectedDate: Date, periodType: PeriodType) {
        let (startDate, endDate) = calculatePeriod(for: selectedDate, periodType: periodType)
        expensesByDate = viewModel.getExpensesForPeriod(startDate: startDate, endDate: endDate)
        print(expensesByDate.count)
     //   expenseMoneyTable.sectionIndexMinimumDisplayRowCount = expensesByDate.count - 1
        labelMoney.text = String(totalAmount)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Формат отображения даты
        navigationItem.title = dateFormatter.string(from: startDate) + " - " + dateFormatter.string(from: endDate)
    }
    
    private func calculatePeriod(for selectedDate: Date, periodType: PeriodType) -> (Date, Date) {
        let currentCalendar = Calendar.current
        var startDate: Date
        var endDate = selectedDate
        
        switch periodType {
        case .day:
            startDate = selectedDate
            endDate = selectedDate// Текущий день
        case .week:
            startDate = currentCalendar.date(from: currentCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
            // Находим конец недели, добавляя 6 дней к началу недели
            endDate = currentCalendar.date(byAdding: .day, value: 6, to: startDate) ?? selectedDate
            
        case .month:
            startDate = currentCalendar.date(from: currentCalendar.dateComponents([.year, .month], from: selectedDate))!
            // Находим конец месяца, добавляя к началу месяца количество дней, равное количеству дней в месяце
            let range = currentCalendar.range(of: .day, in: .month, for: selectedDate)!
            endDate = currentCalendar.date(byAdding: .day, value: range.count - 1, to: startDate)!
            
        case .year:
            startDate = currentCalendar.date(from: currentCalendar.dateComponents([.year], from: selectedDate))!
            // Находим конец года, добавляя 1 год к началу года и вычитая 1 день
            endDate = currentCalendar.date(byAdding: .day, value: -1, to: currentCalendar.date(from: DateComponents(year: currentCalendar.component(.year, from: selectedDate) + 1))!)!
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
        var dateKeys = Array(expensesByDate.keys)
        let dateKey = dateKeys.sorted(by: >)
        return expensesByDate[dateKey[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = expenseMoneyTable.dequeueReusableCell(withIdentifier: "ExpensesTableCell", for: indexPath) as? ExpensesTableCell {
            cell.contentView.backgroundColor = .etBackground
            cell.separatorInset = UIEdgeInsets.zero
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
        if indexPath.row == 0
        {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
    
    
    //MARK: - Headers
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Формат отображения даты
        let headerView = ExpensesTableHeaders()
        var dateKeys = Array(expensesByDate.keys)
        var dateKey = dateKeys.sorted(by: >)
       
    
        let headerTitle = dateFormatter.string(from: dateKey[section])
        headerView.configure(title: headerTitle)
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




