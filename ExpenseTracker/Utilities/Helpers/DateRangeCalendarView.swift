import UIKit

protocol DateRangeCalendarViewDelegate: AnyObject {
    func didSelectDateRange(start: Date, end: Date)
}

final class DateRangeCalendarView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: DateRangeCalendarViewDelegate?
    
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    private var dates: [Date] = []
    private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private let dateRangeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите диапазон дат"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var monthButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.label, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var monthIconButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: Asset.Icon.calendarDropDown.rawValue)?.withTintColor(.etCards), for: .normal)
        button.addTarget(self, action: #selector(monthButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var monthStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.addArrangedSubview(monthButton)
        stack.addArrangedSubview(monthIconButton)
        return stack
    }()
    
    private lazy var monthPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.isHidden = true
        picker.backgroundColor = .systemBackground
        return picker
    }()
    
    private lazy var previousMonthButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: Asset.Icon.previousMonth.rawValue)?.withTintColor(.etCards), for: .normal)
        button.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextMonthButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: Asset.Icon.nextMonth.rawValue)?.withTintColor(.etCards), for: .normal)
        button.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var navigationStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        stack.addArrangedSubview(previousMonthButton)
        stack.addArrangedSubview(nextMonthButton)
        return stack
    }()
    
    private lazy var weekdaysStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        
        let weekdays = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"]
        weekdays.forEach { day in
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16)
            label.textColor = .etCards
            stack.addArrangedSubview(label)
        }
        
        return stack
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        return collection
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.etAccent, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 75).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ОК", for: .normal)
        button.setTitleColor(.etAccent, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 43).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(okButton)
        return stack
    }()
    
    private lazy var topStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.addArrangedSubview(monthStackView)
        stack.addArrangedSubview(navigationStackView)
        return stack
    }()
    
    private lazy var startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Начало периода"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.textColor = .etCards
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 104).isActive = true
        return label
    }()
    
    private lazy var endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Конец периода"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.textColor = .etCards
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 98).isActive = true
        return label
    }()
    
    private lazy var startDateContainer: UIView = {
        let view = UIView()
        view.addSubview(startDateTextField)
        view.addSubview(startDateLabel)
        return view
    }()
    
    private lazy var endDateContainer: UIView = {
        let view = UIView()
        view.addSubview(endDateTextField)
        view.addSubview(endDateLabel)
        return view
    }()
    
    private lazy var startDateTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.isEnabled = false
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .etCards
        textField.layer.borderWidth = 3
        textField.layer.borderColor = UIColor.etAccent.cgColor
        textField.layer.cornerRadius = 4
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return textField
    }()
    
    private lazy var endDateTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.isEnabled = false
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .etCards
        textField.layer.borderWidth = 3
        textField.layer.borderColor = UIColor.etAccent.cgColor
        textField.layer.cornerRadius = 4
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return textField
    }()
    
    private lazy var dateRangeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.addArrangedSubview(startDateContainer)
        stack.addArrangedSubview(endDateContainer)
        return stack
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .etSeparators
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        generateDates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(titleLabel)
        addSubview(dateRangeStackView)
        addSubview(separatorView)
        addSubview(topStackView)
        addSubview(weekdaysStackView)
        addSubview(collectionView)
        addSubview(monthPickerView)
        addSubview(buttonsStackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateRangeStackView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        weekdaysStackView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        monthPickerView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            dateRangeStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            dateRangeStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            dateRangeStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            startDateTextField.topAnchor.constraint(equalTo: startDateContainer.topAnchor),
            startDateTextField.leadingAnchor.constraint(equalTo: startDateContainer.leadingAnchor),
            startDateTextField.trailingAnchor.constraint(equalTo: startDateContainer.trailingAnchor),
            startDateTextField.bottomAnchor.constraint(equalTo: startDateContainer.bottomAnchor),
            
            startDateLabel.centerYAnchor.constraint(equalTo: startDateTextField.topAnchor),
            startDateLabel.leadingAnchor.constraint(equalTo: startDateContainer.leadingAnchor, constant: 12),
            
            endDateTextField.topAnchor.constraint(equalTo: endDateContainer.topAnchor),
            endDateTextField.leadingAnchor.constraint(equalTo: endDateContainer.leadingAnchor),
            endDateTextField.trailingAnchor.constraint(equalTo: endDateContainer.trailingAnchor),
            endDateTextField.bottomAnchor.constraint(equalTo: endDateContainer.bottomAnchor),
            
            endDateLabel.centerYAnchor.constraint(equalTo: endDateTextField.topAnchor),
            endDateLabel.leadingAnchor.constraint(equalTo: endDateContainer.leadingAnchor, constant: 12),
            
            separatorView.topAnchor.constraint(equalTo: dateRangeStackView.bottomAnchor, constant: 28),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            topStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            topStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            topStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            weekdaysStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 30),
            weekdaysStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            weekdaysStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: weekdaysStackView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            
            buttonsStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 40),
            
            monthPickerView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 8),
            monthPickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthPickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            monthPickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        updateMonthLabel()
    }
    
    private func updateDateRangeText() {
        if let startDate = selectedStartDate {
            startDateTextField.text = dateRangeFormatter.string(from: startDate)
        } else {
            startDateTextField.text = nil
        }
        
        if let endDate = selectedEndDate {
            endDateTextField.text = dateRangeFormatter.string(from: endDate)
        } else {
            endDateTextField.text = nil
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func monthButtonTapped() {
        monthPickerView.isHidden.toggle()
        if !monthPickerView.isHidden {
            // Устанавливаем текущий месяц в пикер
            let currentYear = calendar.component(.year, from: currentMonth)
            let currentMonth = calendar.component(.month, from: currentMonth)
            monthPickerView.selectRow(currentMonth - 1, inComponent: 0, animated: false)
            monthPickerView.selectRow(currentYear - 2020, inComponent: 1, animated: false)
        }
    }
    
    @objc
    private func previousMonthTapped() {
        let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        currentMonth = newMonth
        generateDates()
        updateMonthLabel()
        updateNavigationButtons()
        collectionView.reloadData()
    }
    
    @objc
    private func nextMonthTapped() {
        let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        
        // Проверяем, не пытаемся ли мы перейти в будущее
        let currentDate = Date()
        let newMonthYear = calendar.component(.year, from: newMonth)
        let newMonthMonth = calendar.component(.month, from: newMonth)
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        if newMonthYear > currentYear || (newMonthYear == currentYear && newMonthMonth > currentMonth) {
            return // Не позволяем перейти в будущее
        }
        
        self.currentMonth = newMonth
        generateDates()
        updateMonthLabel()
        updateNavigationButtons()
        collectionView.reloadData()
    }
    
    @objc
    private func cancelButtonTapped() {
        hideCalendar()
    }
    
    @objc
    private func okButtonTapped() {
        if let startDate = selectedStartDate, let endDate = selectedEndDate {
            delegate?.didSelectDateRange(start: startDate, end: endDate)
            hideCalendar()
        }
    }
    
    // MARK: - Helpers
    
    private func updateNavigationButtons() {
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        let selectedYear = calendar.component(.year, from: self.currentMonth)
        let selectedMonth = calendar.component(.month, from: self.currentMonth)
        
        // Скрываем кнопку "вперед", если мы уже на текущем месяце
        nextMonthButton.isHidden = selectedYear >= currentYear && selectedMonth >= currentMonth
    }
    
    private func updateMonthLabel() {
        let monthString = dateFormatter.string(from: currentMonth)
        monthButton.setTitle(monthString.prefix(1).uppercased() + monthString.dropFirst(), for: .normal)
        updateNavigationButtons()
    }
    
    private func generateDates() {
        dates.removeAll()
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return
        }
        
        // Получаем первый день месяца
        let firstDayOfMonth = monthInterval.start
        
        // Получаем последний день месяца
        let lastDayOfMonth = monthInterval.end - 1
        
        // Получаем день недели для первого дня месяца (1 = воскресенье, 2 = понедельник, и т.д.)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Вычисляем количество дней, которые нужно добавить в начало
        // Если первый день месяца - понедельник (2), то добавляем 1 день
        // Если вторник (3) - добавляем 2 дня и т.д.
        let daysToAdd = firstWeekday == 1 ? 6 : firstWeekday - 2
        
        // Добавляем дни предыдущего месяца
        if daysToAdd > 0 {
            let previousMonthDate = calendar.date(byAdding: .day, value: -daysToAdd, to: firstDayOfMonth) ?? firstDayOfMonth
            for i in 0..<daysToAdd {
                if let date = calendar.date(byAdding: .day, value: i, to: previousMonthDate) {
                    dates.append(date)
                }
            }
        }
        
        // Добавляем дни текущего месяца
        var currentDate = firstDayOfMonth
        while currentDate <= lastDayOfMonth {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Добавляем дни следующего месяца, чтобы заполнить последнюю неделю
        let remainingDays = 7 - (dates.count % 7)
        if remainingDays < 7 {
            for i in 1...remainingDays {
                if let date = calendar.date(byAdding: .day, value: i, to: lastDayOfMonth) {
                    dates.append(date)
                }
            }
        }
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        guard let startDate = selectedStartDate, let endDate = selectedEndDate else {
            return date == selectedStartDate
        }
        
        return date >= startDate && date <= endDate
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        guard let startDate = selectedStartDate, let endDate = selectedEndDate else {
            return false
        }
        
        return date > startDate && date < endDate
    }
    
    static func show(in viewController: UIViewController, delegate: DateRangeCalendarViewDelegate) {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let calendarView = DateRangeCalendarView()
        calendarView.delegate = delegate
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.backgroundColor = .systemBackground
        calendarView.layer.cornerRadius = 28
        
        viewController.view.addSubview(containerView)
        containerView.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            
            calendarView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            calendarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            calendarView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -32),
            calendarView.heightAnchor.constraint(equalToConstant: 540)
        ])
        
        // Анимация появления
        containerView.alpha = 0
        calendarView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3) {
            containerView.alpha = 1
            calendarView.transform = .identity
        }
    }
    
    private func hideCalendar() {
        UIView.animate(withDuration: 0.3, animations: {
            self.superview?.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.superview?.removeFromSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension DateRangeCalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else { return UICollectionViewCell() }
        let date = dates[indexPath.item]
        
        let day = calendar.component(.day, from: date)
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        
        if isCurrentMonth {
            if isDateSelected(date) {
                cell.setSelected(true)
            } else if isDateInRange(date) {
                cell.setInRange(true)
            } else {
                cell.setSelected(false)
                cell.setInRange(false)
            }
            cell.configure(day: day, isCurrentMonth: true, isToday: isToday)
        } else {
            cell.configure(day: day, isCurrentMonth: false, isToday: false)
            cell.setHidden(true)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension DateRangeCalendarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = dates[indexPath.item]
        
        if selectedStartDate == nil {
            selectedStartDate = selectedDate
            selectedEndDate = nil
        } else if selectedEndDate == nil {
            if selectedDate == selectedStartDate {
                // Если нажали на ту же дату, снимаем выделение
                selectedStartDate = nil
            } else if selectedDate < selectedStartDate! {
                selectedEndDate = selectedStartDate
                selectedStartDate = selectedDate
            } else {
                selectedEndDate = selectedDate
            }
            
            if let start = selectedStartDate, let end = selectedEndDate {
                delegate?.didSelectDateRange(start: start, end: end)
            }
        } else {
            if selectedDate == selectedStartDate || selectedDate == selectedEndDate {
                // Если нажали на одну из выбранных дат, сбрасываем выбор
                selectedStartDate = nil
                selectedEndDate = nil
            } else {
                selectedStartDate = selectedDate
                selectedEndDate = nil
            }
        }
        updateDateRangeText()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DateRangeCalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 7
        return CGSize(width: width, height: width)
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource

extension DateRangeCalendarView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12 // месяцы
        } else {
            let currentYear = calendar.component(.year, from: Date())
            return currentYear - 2019 // от 2020 до текущего года
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let month = row + 1
            let date = calendar.date(from: DateComponents(year: 2020, month: month))!
            return dateFormatter.string(from: date).components(separatedBy: " ").first
        } else {
            return "\(2020 + row)"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedMonth = monthPickerView.selectedRow(inComponent: 0) + 1
        let selectedYear = monthPickerView.selectedRow(inComponent: 1) + 2020
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        // Проверяем, не выбрана ли дата в будущем
        if selectedYear > currentYear || (selectedYear == currentYear && selectedMonth > currentMonth) {
            // Если выбрана дата в будущем, возвращаем к текущей дате
            monthPickerView.selectRow(currentMonth - 1, inComponent: 0, animated: true)
            monthPickerView.selectRow(currentYear - 2020, inComponent: 1, animated: true)
            return
        }
        
        if let newDate = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
            self.currentMonth = newDate
            generateDates()
            updateMonthLabel()
            updateNavigationButtons()
            collectionView.reloadData()
            monthPickerView.isHidden = true
        }
    }
}

// MARK: - DateCell

final class DateCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 21
        view.clipsToBounds = true
        view.layer.borderWidth = 0
        return view
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isSelectedState: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dayLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func configure(day: Int, isCurrentMonth: Bool, isToday: Bool) {
        dayLabel.text = "\(day)"
        
        if isSelectedState {
            containerView.backgroundColor = .etAccent
            dayLabel.textColor = .white
            containerView.layer.borderWidth = 0
        } else if isToday {
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.etAccent.cgColor
            dayLabel.textColor = .etAccent
        } else {
            containerView.layer.borderWidth = 0
            dayLabel.textColor = isCurrentMonth ? .etCards : .white
        }
    }
    
    func setSelected(_ selected: Bool) {
        isSelectedState = selected
        if selected {
            containerView.backgroundColor = .etAccent
            dayLabel.textColor = .white
            containerView.layer.borderWidth = 0
        } else {
            containerView.backgroundColor = .clear
            dayLabel.textColor = .etButtonLabel
        }
    }
    
    func setInRange(_ inRange: Bool) {
        if inRange {
            containerView.backgroundColor = UIColor.etAccent.withAlphaComponent(0.2)
            dayLabel.textColor = .etAccent
            containerView.layer.borderWidth = 0
        } else {
            containerView.backgroundColor = .clear
            dayLabel.textColor = .etButtonLabel
        }
    }
    
    func setHidden(_ hidden: Bool) {
        dayLabel.textColor = .clear
        containerView.backgroundColor = .clear
        containerView.layer.borderWidth = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelectedState = false
        containerView.backgroundColor = .clear
        dayLabel.textColor = .etButtonLabel
        containerView.layer.borderWidth = 0
    }
}
