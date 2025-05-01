import UIKit

final class CategorySelectionCell: UITableViewCell {
    
    // MARK: - Reuse Identifier
    
    static let reuseIdentifier = "CategorySelectionCell"
    
    // MARK: - UI Elements
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .etIconsBG
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .etPrimaryLabel
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let customSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .etSeparators
        return view
    }()
    
    // MARK: - Properties
    
    private var isCellSelected: Bool = false {
        didSet {
            updateCheckmarkVisibility()
        }
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.image = nil
        checkmarkImageView.image = nil
        isCellSelected = false
    }
    
    // MARK: - Public Methods
    
    func configure(with category: CategoryMain) {
        titleLabel.text = category.title
        titleLabel.applyTextStyle(.body, textStyle: .body)
        iconImageView.image = UIImage(named: category.icon.rawValue)?.withTintColor(.etIcons)
        isCellSelected = isSelected
    }
    
    func setupLastCell() {
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.masksToBounds = true
        customSeparator.removeFromSuperview()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        setupContentView()
        setupViews()
        setupLayout()
        setupAccessibility()
    }
    
    private func setupContentView() {
        backgroundColor = .etCardsToggled
        selectionStyle = .none
    }
    
    private func setupViews() {
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        
        [titleLabel, checkmarkImageView, customSeparator].forEach {
            contentView.addSubview($0)
        }
        
        [iconContainer, iconImageView, titleLabel, checkmarkImageView, customSeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Icon Container
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32),
            
            // Icon Image
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Checkmark
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Separator
            customSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            customSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func updateCheckmarkVisibility() {
        checkmarkImageView.isHidden = !isCellSelected
        checkmarkImageView.image = isCellSelected
            ? UIImage(named: Asset.Icon.checkboxPressed.rawValue)
            : nil
    }
    
    private func setupAccessibility() {
        titleLabel.accessibilityIdentifier = "categoryTitleLabel"
        iconImageView.accessibilityIdentifier = "categoryIcon"
        checkmarkImageView.accessibilityIdentifier = "checkmarkIcon"
    }
}
