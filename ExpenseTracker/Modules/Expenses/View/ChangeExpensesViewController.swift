import UIKit

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

class ChangeExpensesViewController: UIViewController, UITextViewDelegate {
    
    private let newCategory: NewCategory
    private var currentDate: Int?
    var categoryName: String = ""
    var categoryImageName: String = ""
    
    private lazy var  addCategory: AddCategoryView = {
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
    
    private lazy var  addDate: AddDateView = {
        let addDate = AddDateView(frame: .zero)
        addDate.layer.cornerRadius = 12
        addDate.backgroundColor = .etCardsToggled
   //     addDate.addCategoryButton(nil, action: #selector(addDateButton))
        addDate.translatesAutoresizingMaskIntoConstraints = false
        return addDate
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.tintColor = .etAccent
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "dd.MM.yyyy"
      //  var  dateLabel = dateFormatter.string(from: datePicker.date)
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var addMoney: MoneyTextField = {
        let addMoney = MoneyTextField(placeholder: "")
        addMoney.setupToggleButton(Asset.Icon.currencyRuble.rawValue)
        addMoney.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return addMoney
    }()
    
    private lazy var addNote: UITextView = {
        let addNote = UITextView()
        addNote.translatesAutoresizingMaskIntoConstraints = false
        addNote.isScrollEnabled = true
        addNote.backgroundColor = UIColor.white
        addNote.layer.cornerRadius = 12
        return addNote
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        // Настройка UILabel для плейсхолдера
        placeholderLabel.text = "Примечание"
        placeholderLabel.font = AppTextStyle.body.font
        placeholderLabel.textColor = .etInactive
        placeholderLabel.frame.origin = CGPoint(x: 10, y: 15) // Положение плейсхолдера
        placeholderLabel.sizeToFit()
        return placeholderLabel
    }()
    
    private lazy var saveButton: MainButton = {
        let saveButton = MainButton(title: newCategory.saveButtonText)
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
        self.navigationController?.setNavigationBarHidden(true, animated: .init())
        setupCustomNavBar(title: newCategory.titleText, backAction: #selector(cancelButtonAction))
        addSubviews()
        setupLayout()
        updatePlaceholderVisibility()
        setupNote()
        updateSaveButton()
        
    }
    
   
    
    
    @objc private func cancelButtonAction() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func addCategoryButton() {
        print("Окно категорий")
    }
//    
//    @objc private func addDateButton() {
//        // Инициализация и отображение UIDatePicker
//        var datePicker = datePicker
//        datePicker.preferredDatePickerStyle = .compact
//        datePicker.datePickerMode = .date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy"
//        datePicker.locale = Locale(identifier: "ru_RU")
//        datePicker.accessibilityLabel = dateFormatter.string(from: datePicker.date)
//        //   datePicker.addTarget(self, action: #selector(dateChangedLabel), for: .valueChanged)
//        
//        let alert = UIAlertController(title: "Выберите дату", message: "\n\n\n\n\n\n\n", preferredStyle: .alert)
//        alert.view.addSubview(datePicker)
//        
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            datePicker.heightAnchor.constraint(equalToConstant: 200),
//            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
//            datePicker.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor)
//        ])
//        
//        alert.addAction(UIAlertAction(title: "Готово", style: .cancel) { _ in
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd.MM.yyyy"
//            var  dateLabel = dateFormatter.string(from: datePicker.date)
//    //        self.addDate.configure(with: dateLabel)
//
//            print("Кнопка Отмена нажата")
//        })
//        present(alert, animated: true, completion: nil)
//    }
    
    func setupNote() {
        addNote.delegate = self
        addNote.font = AppTextStyle.body.font
        addNote.textColor = .etCards
    }
    
    func addSubviews() {
        view.addSubview(addDate)
     //   addDate.addSubview(datePicker)
        view.addSubview(datePicker)
        view.addSubview(addMoney)
        view.addSubview(addNote)
        addNote.addSubview(placeholderLabel)
        view.addSubview(saveButton)
    }
    
    //MARK: func addNote
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !addNote.text.isEmpty
    }
    
    func setupLayout() {
        
        var constraints = [
            addDate.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 107),
            addDate.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addDate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addDate.heightAnchor.constraint(equalToConstant: 50),
            
            datePicker.centerYAnchor.constraint(equalTo: addDate.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: addDate.leadingAnchor, constant: 8),
      //      datePicker.trailingAnchor.constraint(equalTo: addDate.trailingAnchor, constant: -16),
      //      datePicker.heightAnchor.constraint(equalToConstant: 50),
            
            addMoney.topAnchor.constraint(equalTo: addDate.bottomAnchor, constant: 12),
            addMoney.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addMoney.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addMoney.heightAnchor.constraint(equalToConstant: 50),
            
            addNote.topAnchor.constraint(equalTo: addMoney.bottomAnchor, constant: 12),
            addNote.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addNote.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addNote.heightAnchor.constraint(equalToConstant: 120),
            
            saveButton.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
            
        ]
        
        if newCategory == .add {
            view.addSubview(addCategory)
            constraints += [
                addCategory.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
                addCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                addCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                addCategory.heightAnchor.constraint(equalToConstant: 50)
            ]
        }
        else {
            view.addSubview(changeCategory)
            constraints += [
                changeCategory.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
                changeCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                changeCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                changeCategory.heightAnchor.constraint(equalToConstant: 50)
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func textFieldChanged() {
        updateSaveButton()
    }
    
    func updateSaveButton() {
        saveButton.isEnabled = addMoney.text?.isEmpty == false && Double(addMoney.text ?? "") != nil
        if saveButton.isEnabled {
            saveButton.backgroundColor = .etAccent
        } else {
            saveButton.backgroundColor = .etInactive
        }
    }
}



