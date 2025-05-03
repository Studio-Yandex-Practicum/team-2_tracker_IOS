import UIKit

class ExpensesTableHeaders: UITableViewHeaderFooterView {
    
    static let identifier = "ExpensesTableHeaders"

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.button.font
        label.textColor = .etPrimaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ])
    }

    func configure(title: Date) {
        let startOfDateToCheck = Calendar.current.startOfDay(for: Date())
        
        // Форматируем дату без года для сравнения с сегодняшней
        let currentYear = Calendar.current.component(.year, from: Date())
        let titleYear = Calendar.current.component(.year, from: title)
        
        if startOfDateToCheck == title {
            titleLabel.text = "Сегодня"
        } else {
            let formattedDate = dateFormatter.string(from: title)
            if currentYear != titleYear {
                // Добавляем год, если он не совпадает с текущим
                titleLabel.text = "\(formattedDate) \(titleYear)"
            } else {
                titleLabel.text = formattedDate
            }
        }
    }
}
