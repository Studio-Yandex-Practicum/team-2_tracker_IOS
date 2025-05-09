import UIKit

protocol CreateExpenseDelegate: AnyObject {
    func createExpense(_ newExpense: Expense)
}

enum NewCategory {
    
    case add
    case change
    
    var titleText: String {
        switch self {
        case .add:
            return "Добавить расход"
        case .change:
            return "Редактировать расход"
        }
    }
    
    var saveButtonText: String {
        switch self {
        case .add:
            return "Добавить"
        case .change:
            return "Сохранить"
        }
    }
}

final class ChangeExpensesViewController: UIViewController, UITextViewDelegate {
       
    weak var delegate: CreateExpenseDelegate?
    weak var coordinator: ExpensesCoordinator?
    private var customNavigationBar: CustomBackBarItem?
    
    private let newCategory: NewCategory
    private var currentDate: Int?
    private var  newAddExpense = true
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private lazy var addCategory: AddCategoryView = {
        let addCategory = AddCategoryView(frame: .zero)
        addCategory.layer.cornerRadius = 12
        addCategory.backgroundColor = .etCardsToggled
        addCategory.addCategoryButton(nil, action: #selector(addCategoryButton))
        addCategory.translatesAutoresizingMaskIntoConstraints = false
        return addCategory
    }()
    
    private lazy var changeCategory: ChangeCategoryView = {
        let changeCategory = ChangeCategoryView(frame: .zero)
        changeCategory.layer.cornerRadius = 12
        changeCategory.backgroundColor = .etCardsToggled
        changeCategory.addCategoryButton(nil, action: #selector(addCategoryButton))
        changeCategory.translatesAutoresizingMaskIntoConstraints = false
        return changeCategory
    }()
    
    private lazy var addDate: AddDateView = {
        let addDate = AddDateView(frame: .zero)
        addDate.layer.cornerRadius = 12
        addDate.backgroundColor = .etCardsToggled
        addDate.addCategoryButton(nil, action: #selector(showDatePicker))
        addDate.isUserInteractionEnabled = true
        addDate.translatesAutoresizingMaskIntoConstraints = false
        return addDate
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ru_RU")
        picker.tintColor = .etAccent
        picker.backgroundColor = .clear
        picker.maximumDate = Date() // Устанавливаем максимальную дату как сегодняшнюю
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var addMoney: MoneyTextField = {
        let addMoney = MoneyTextField(placeholder: "Сумма расхода")
        addMoney.moneyTextFieldDelegate = self
        addMoney.setupToggleButton(Asset.Icon.currencyRuble.rawValue)
        addMoney.textColor = .etCards
        addMoney.keyboardType = .decimalPad
        addMoney.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return addMoney
    }()
    
    private lazy var addNote: UITextView = {
        let addNote = UITextView()
        addNote.translatesAutoresizingMaskIntoConstraints = false
        addNote.isScrollEnabled = true
        addNote.backgroundColor = .etCardsToggled
        addNote.layer.cornerRadius = 12
        addNote.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return addNote
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        // Настройка UILabel для плейсхолдера
        placeholderLabel.text = "Добавьте детали о расходе (необязательно)"
        placeholderLabel.font = AppTextStyle.body.font
        placeholderLabel.textColor = .etSecondaryLabel
        placeholderLabel.frame.origin = CGPoint(x: 16, y: 12) // Положение плейсхолдера
        placeholderLabel.sizeToFit()
        return placeholderLabel
    }()
    
    private lazy var saveButton: MainButton = {
        let saveButton = MainButton(title: newCategory.saveButtonText)
        saveButton.isEnabled = true
        saveButton.backgroundColor = .etInactive
        return saveButton
    }()

    init(_ newCategory: NewCategory) {
        self.newCategory = newCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .etBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        customNavigationBar = setupCustomNavBar(title: newCategory.titleText, backAction: #selector(cancelButtonAction))
        
        addSubviews()
        setupLayout()
        updatePlaceholderVisibility()
        setupNote()
        setupSaveCategoryButton()
    }
    
    private func setupGestures() {
        setupGesture(for: addCategory, action: #selector(showCategorySelectionFlow))
        setupGesture(for: addDate, action: #selector(showDatePicker))
    }
    
    private func setupGesture(for view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func cancelButtonAction() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    private func addCategoryButton() {
        coordinator?.showCategorySelectionOneFlow(with: self)
    }
    
    func setupNote() {
        addNote.delegate = self
        addNote.font = AppTextStyle.body.font
        addNote.textColor = .etPrimaryLabel
        updatePlaceholderVisibility()
    }
    
    func addSubviews() {
        view.addSubview(addDate)
        view.addSubview(addMoney)
        view.addSubview(addNote)
        addNote.addSubview(placeholderLabel)
        view.addSubview(saveButton)
    }
    
    // MARK: func addNote
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    func updatePlaceholderVisibility() {
        // Показываем плейсхолдер, если текст пустой
        placeholderLabel.isHidden = !addNote.text.isEmpty
    }
    
    func setupLayout() {
        guard let customNavigationBar else { return }
        
        var constraints = [
            addDate.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: 76),
            addDate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addDate.heightAnchor.constraint(equalToConstant: 50),
            
            addMoney.topAnchor.constraint(equalTo: addDate.bottomAnchor, constant: 12),
            addMoney.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addMoney.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addMoney.heightAnchor.constraint(equalToConstant: 50),
            
            addNote.topAnchor.constraint(equalTo: addMoney.bottomAnchor, constant: 12),
            addNote.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addNote.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addNote.heightAnchor.constraint(equalToConstant: 120),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ]
        
        if newCategory == .add {
            if newAddExpense == true {
                view.addSubview(addCategory)
                constraints += [
                    addCategory.bottomAnchor.constraint(equalTo: addDate.topAnchor, constant: -12),
                    addCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    addCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    addCategory.heightAnchor.constraint(equalToConstant: 50)
                    ]
                    } else {
                        view.addSubview(changeCategory)
                        constraints += [
                            changeCategory.bottomAnchor.constraint(equalTo: addDate.topAnchor, constant: -12),
                            changeCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                            changeCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                            changeCategory.heightAnchor.constraint(equalToConstant: 50)
                            ]
                    }
        } else {
            view.addSubview(changeCategory)
            constraints += [
                changeCategory.bottomAnchor.constraint(equalTo: addDate.topAnchor, constant: -12),
                changeCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                changeCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                changeCategory.heightAnchor.constraint(equalToConstant: 50)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc
    private func showCategorySelectionFlow() {
        coordinator?.showCategorySelectionFlow()
    }
    
    @objc
    private func textFieldChanged() {
        // Форматируем введенное значение
        if let text = addMoney.text?.replacingOccurrences(of: ",", with: ".") {
            let components = text.components(separatedBy: ".")
            if components.count > 2 {
                // Если введено больше одной точки, оставляем только первую
                let firstPart = components[0]
                let secondPart = components[1]
                addMoney.text = firstPart + "." + secondPart
            }
            
            // Ограничиваем количество знаков после запятой до 2
            if let decimalPart = components.last, components.count > 1 {
                if decimalPart.count > 2 {
                    let index = decimalPart.index(decimalPart.startIndex, offsetBy: 2)
                    let truncatedDecimal = decimalPart[..<index]
                    addMoney.text = components[0] + "." + truncatedDecimal
                }
            }
        }
        updateButtonState()
    }
    
    @objc private func addComma() {
        if let text = addMoney.text, !text.contains(",") {
            addMoney.text = text + ","
        }
    }
    
    @objc private func doneButtonTapped() {
        addMoney.resignFirstResponder()
    }
        
    private func setupSaveCategoryButton() {
        saveButton.addTarget(self, action: #selector(saveNewExpense), for: .touchUpInside)
    }
    
    private func convertToDecimal(from text: String) -> Decimal {
        // Удаляем пробелы
        let cleanedString = text.replacingOccurrences(of: " ", with: "")

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ru_RU") // В русской локали запятая — десятичный разделитель

        if let number = formatter.number(from: cleanedString) {
            let decimal = number.decimalValue
            return decimal
        }
        return 0
    }
    
    @objc
    private func showDatePicker() {
        let alert = UIAlertController(title: "Выберите дату", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40),
            datePicker.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            let selectedDate = dateFormatter.string(from: datePicker.date)
            addDate.setLabel(selectedDate)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc
    private func saveNewExpense() {
        newAddExpense = true
        guard
            let stringAmount = addMoney.text,
            let category = changeCategory.categoryLabel.text
        else { return }
        
        let decimalAmount = convertToDecimal(from: stringAmount)
        print(decimalAmount)
        let expense = Expense(id: UUID(), expense: decimalAmount, category: Category(id: UUID(), name: category, icon: Asset.Icon.cafe), date: datePicker.date, note: addNote.text)

        delegate?.createExpense(expense)
        coordinator?.dismissCurrentFlow()
    }
}

extension ChangeExpensesViewController: MoneyTextFieldDelegate {
    
    func updateButtonState() {
        guard
            let stringAmount = addMoney.text, addMoney.text != "0",
            let category = changeCategory.categoryLabel.text, !category.isEmpty
        else { return }
        
        let amount = convertToDecimal(from: stringAmount)
        saveButton.isEnabled = amount > 0
        
        if saveButton.isEnabled {
            saveButton.backgroundColor = .etAccent
        } else {
            saveButton.backgroundColor = .etInactive
        }
    }
}

extension ChangeExpensesViewController: CategoryForExpenseDelegate {
    
    func didSelectCategoryForExpense(_ categories: CategoryMain) {
        newAddExpense = false
        setupLayout()
        changeCategory.categoryLabel.text = categories.title
        changeCategory.categoryImage.image = UIImage(named: categories.icon.rawValue)?.withTintColor(.etButtonLabel)
        updateButtonState()
    }
}
