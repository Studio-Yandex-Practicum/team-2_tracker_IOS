import UIKit

final class CategorySelectionCell: UITableViewCell {

    // MARK: - Reuse Identifier
    static let reuseIdentifier = "CategorySelectionCell"

    // MARK: - UI Elements

    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .etCardsToggled
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

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

    var isCellSelected: Bool = false {
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
        backgroundContainerView.layer.maskedCorners = []
        customSeparator.isHidden = false
    }

    // MARK: - Public Methods

    func configure(with category: CategoryMain, isFirst: Bool, isLast: Bool) {
        titleLabel.text = category.title
        titleLabel.applyTextStyle(.body, textStyle: .body)
        iconImageView.image = UIImage(named: category.icon.rawValue)?.withTintColor(.etIcons)
        isCellSelected = isSelected

        applyCorners(isFirst: isFirst, isLast: isLast)
    }

    // MARK: - Private Methods

    private func applyCorners(isFirst: Bool, isLast: Bool) {
        var corners: CACornerMask = []
        
        if isLast {
            corners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }
        backgroundContainerView.layer.maskedCorners = corners

        // Скрыть сепаратор, если это последняя ячейка
        customSeparator.isHidden = isLast
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(backgroundContainerView)
        backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        backgroundContainerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        backgroundContainerView.addSubview(titleLabel)
        backgroundContainerView.addSubview(checkmarkImageView)
        backgroundContainerView.addSubview(customSeparator)

        [iconContainer, iconImageView, titleLabel, checkmarkImageView, customSeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),

            checkmarkImageView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),

            customSeparator.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor),
            customSeparator.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor),
            customSeparator.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor),
            customSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])

        setupAccessibility()
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
