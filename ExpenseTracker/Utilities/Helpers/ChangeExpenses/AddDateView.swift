import UIKit

final class AddDateView: UIView {
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private let categoryButton: UIButton = {
        let categoryButton = UIButton()
        categoryButton.backgroundColor = .etCardsToggled
        categoryButton.setImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etCards), for: .normal)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        return categoryButton
    }()
    
    private lazy var categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.textColor = .etCards
        categoryLabel.text = dateFormatter.string(from: Date(timeIntervalSinceNow: 0))
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.applyTextStyle(.body, textStyle: .body)
        return categoryLabel
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLabel(_ label: String) {
        categoryLabel.text = label
    }
    
    func setupView() {
        
        self.addSubview(categoryLabel)
        self.addSubview(categoryButton)
        
        NSLayoutConstraint.activate([
            
            categoryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
            
            categoryButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            categoryButton.widthAnchor.constraint(equalToConstant: 44),
            categoryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
     func addCategoryButton(_ target: Any?, action: Selector) {
        categoryButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
//    func configure(with text: String) {
//        categoryLabel.text = text
//       }
}
