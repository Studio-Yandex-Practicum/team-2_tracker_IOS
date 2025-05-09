import UIKit

final class AnalyticsTableCell: UITableViewCell {

    // MARK: - Model
    struct AnalyticsCellModel {
        let category: String
        let icon: Asset.Icon
        let amount: Decimal
        let percentage: Double?
        let color: UIColor
        let currency: String
        let isSubCategory: Bool
    }
    
    var currency = Currency.ruble.rawValue
    
    private lazy var backView: UIView = {
        let backView = UIView()
        backView.backgroundColor = .etCardsToggled
        backView.translatesAutoresizingMaskIntoConstraints = false
        return backView
    }()
    
     lazy var expenceView: UIView = {
        let expenceView = UIView()
        expenceView.backgroundColor = .etIconsBG
        expenceView.layer.cornerRadius = 16
        expenceView.translatesAutoresizingMaskIntoConstraints = false
        return expenceView
    }()
    
    private lazy var expenceImage: UIImageView = {
        let expenceImage = UIImageView()
        expenceImage.image = UIImage(named: Asset.Icon.cafe.rawValue)?.withTintColor(.etButtonLabel) // будет меняться
        expenceImage.translatesAutoresizingMaskIntoConstraints = false
        return expenceImage
    }()
    
    lazy var categoryMoney: UILabel = {
        let labelMoney = UILabel()
        labelMoney.text = "Категория" // переменная
        labelMoney.textColor = .etPrimaryLabel
        labelMoney.font = AppTextStyle.body.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        return labelMoney
    }()
    
    lazy var percentMoney: UILabel = {
        let labelMoney = UILabel()
        labelMoney.text = "15%" // переменная
        labelMoney.textColor = .etSecondaryLabel
        labelMoney.font = AppTextStyle.body.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        return labelMoney
    }()
    
    private lazy var labelMoneyCash: UILabel = {
        let labelMoney = UILabel()
        labelMoney.text = "500"
        labelMoney.textColor = .etPrimaryLabel
        labelMoney.font = AppTextStyle.body.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        return labelMoney
    }()
    
    private let customSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .etSeparators
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        setupCell()
    }
    
    func addSubviews() {
        expenceView.addSubview(expenceImage)
        contentView.addSubview(backView)
        backView.addSubview(expenceView)
        backView.addSubview(labelMoneyCash)
        backView.addSubview(categoryMoney)
        backView.addSubview(percentMoney)
        backView.addSubview(customSeparator)
    }
    
    func setupCell() {
        // Базовые настройки ячейки
        contentView.backgroundColor = .etBackground
        separatorInset = UIEdgeInsets.zero
        selectionStyle = .none
        translatesAutoresizingMaskIntoConstraints = true
        
        var constraints = [
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            expenceView.heightAnchor.constraint(equalToConstant: 32),
            expenceView.widthAnchor.constraint(equalToConstant: 32),
            expenceView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            expenceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            expenceImage.centerYAnchor.constraint(equalTo: expenceView.centerYAnchor),
            expenceImage.centerXAnchor.constraint(equalTo: expenceView.centerXAnchor),
            expenceImage.heightAnchor.constraint(equalToConstant: 20),
            expenceImage.widthAnchor.constraint(equalToConstant: 20),
            
            labelMoneyCash.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            labelMoneyCash.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16),
            
            categoryMoney.leadingAnchor.constraint(equalTo: expenceImage.trailingAnchor, constant: 16),
            categoryMoney.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -68),
            
            percentMoney.leadingAnchor.constraint(equalTo: expenceImage.trailingAnchor, constant: 16),
            percentMoney.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -48),
            
            customSeparator.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            customSeparator.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            customSeparator.bottomAnchor.constraint(equalTo: backView.bottomAnchor),
            customSeparator.heightAnchor.constraint(equalToConstant: 1)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with viewModel: AnalyticsCellModel) {
        categoryMoney.text = viewModel.category
        expenceView.backgroundColor = viewModel.color
        expenceImage.image = UIImage(named: viewModel.icon.rawValue)?.withTintColor(.etButtonLabel)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = ","
        
        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: viewModel.amount)) {
            labelMoneyCash.text = formattedAmount + " " + viewModel.currency
        }
        
        // Удаляем старые констрейнты
        categoryMoney.removeFromSuperview()
        percentMoney.removeFromSuperview()
        expenceView.removeFromSuperview()
        backView.addSubview(expenceView)
        backView.addSubview(categoryMoney)
        backView.addSubview(percentMoney)
        
        if viewModel.isSubCategory {
            // Для подкатегорий центрируем название по вертикали и увеличиваем отступ слева
            NSLayoutConstraint.activate([
                expenceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
                expenceView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                expenceView.heightAnchor.constraint(equalToConstant: 32),
                expenceView.widthAnchor.constraint(equalToConstant: 32),
                
                categoryMoney.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
                categoryMoney.leadingAnchor.constraint(equalTo: expenceImage.trailingAnchor, constant: 16),
                categoryMoney.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -68)
            ])
            percentMoney.isHidden = true
        } else {
            // Для основных категорий показываем проценты
            NSLayoutConstraint.activate([
                expenceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                expenceView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                expenceView.heightAnchor.constraint(equalToConstant: 32),
                expenceView.widthAnchor.constraint(equalToConstant: 32),
                
                categoryMoney.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                categoryMoney.leadingAnchor.constraint(equalTo: expenceImage.trailingAnchor, constant: 16),
                categoryMoney.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -68),
                
                percentMoney.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                percentMoney.leadingAnchor.constraint(equalTo: expenceImage.trailingAnchor, constant: 16),
                percentMoney.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -48)
            ])
            percentMoney.isHidden = false
            
            if let percentage = viewModel.percentage {
                // Округляем процент по правилам математического округления
                let roundedPercentage = Int(round(percentage))
                percentMoney.text = "\(roundedPercentage)%"
            } else {
                percentMoney.text = nil
            }
        }
    }
    
    func hideSeparator() {
        customSeparator.isHidden = true
    }
    
    func showSeparator() {
        customSeparator.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryMoney.text = nil
        labelMoneyCash.text = nil
        percentMoney.text = nil
        expenceView.backgroundColor = .etIconsBG
        percentMoney.isHidden = false
        customSeparator.isHidden = false
        
        // Удаляем все констрейнты при переиспользовании ячейки
        categoryMoney.removeFromSuperview()
        percentMoney.removeFromSuperview()
        expenceView.removeFromSuperview()
        backView.addSubview(expenceView)
        backView.addSubview(categoryMoney)
        backView.addSubview(percentMoney)
    }
}
