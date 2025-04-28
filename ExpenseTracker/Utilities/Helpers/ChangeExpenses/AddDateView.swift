import UIKit

final class AddDateView: UIView {
    
    private let categoryButton: UIButton = {
        let categoryButton = UIButton()
        categoryButton.backgroundColor = .etCardsToggled
        categoryButton.setBackgroundImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etCards), for: .normal)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        return categoryButton
    }()
    
//    private lazy var categoryLabel: UILabel = {
//        let categoryLabel = UILabel()
//        categoryLabel.font = AppTextStyle.body.font
//        categoryLabel.textColor = .etCards
//        categoryLabel.text = "23.04.2025"
//        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
//        return categoryLabel
//    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
     //   self.addSubview(categoryLabel)
        self.addSubview(categoryButton)
        
        NSLayoutConstraint.activate([
            
//            categoryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            categoryLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
//            categoryLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
            
            categoryButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            categoryButton.widthAnchor.constraint(equalToConstant: 24),
            categoryButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
     func addCategoryButton(_ target: Any?, action: Selector) {
        categoryButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
//    func configure(with text: String) {
//        categoryLabel.text = text
//       }
}
