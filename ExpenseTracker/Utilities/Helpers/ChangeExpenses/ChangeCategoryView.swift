import UIKit

final class ChangeCategoryView: UIView {
    
    private lazy var categoryView: UIView = {
        let expenceView = UIView()
        expenceView.backgroundColor = .etIconsBG
        expenceView.layer.cornerRadius = 16
        expenceView.translatesAutoresizingMaskIntoConstraints = false
        return expenceView
    }()
    
    private lazy var categoryImage: UIImageView = {
        let categoryImage = UIImageView()
        categoryImage.image = UIImage(named: Asset.Icon.cafe.rawValue)?.withTintColor(.etButtonLabel) // будет меняться
        categoryImage.translatesAutoresizingMaskIntoConstraints = false
        return categoryImage
    }()
    
    private let categoryButton: UIButton = {
        let categoryButton = UIButton()
        categoryButton.backgroundColor = .etCardsToggled
        categoryButton.setBackgroundImage(UIImage(named: Asset.Icon.edit.rawValue)?.withTintColor(.etCards), for: .normal)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        return categoryButton
    }()
    
    private let categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.font = AppTextStyle.body.font
        categoryLabel.textColor = .etCards
        categoryLabel.text = "Здоровье"
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        return categoryLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        categoryView.addSubview(categoryImage)
        self.addSubview(categoryView)
        self.addSubview(categoryLabel)
        self.addSubview(categoryButton)
        
        NSLayoutConstraint.activate([
            categoryView.heightAnchor.constraint(equalToConstant: 32),
            categoryView.widthAnchor.constraint(equalToConstant: 32),
            categoryView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            categoryView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            categoryImage.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor),
            categoryImage.centerXAnchor.constraint(equalTo: categoryView.centerXAnchor),
            
            categoryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
            
            categoryButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            categoryButton.widthAnchor.constraint(equalToConstant: 24),
            categoryButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func addCategoryButton(_ target: Any?, action: Selector) {
       categoryButton.addTarget(target, action: action, for: .touchUpInside)
   }
    
    func configure(with text: String, image: UIImage?) {
        categoryImage.image = image
        categoryLabel.text = text
       }
}
