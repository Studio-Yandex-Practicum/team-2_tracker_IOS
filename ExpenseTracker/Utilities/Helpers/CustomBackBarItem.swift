import UIKit

final class CustomBackBarItem: UIStackView {

    // MARK: - Subviews

    private let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: Asset.Icon.arrowBack.rawValue)?
            .withTintColor(.etPrimaryLabel)
        button.setImage(image, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    private let navigationTitleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .etPrimaryLabel
        label.text = AuthAction.registration.rawValue
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.applyTextStyle(.h1, textStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(
        title: String,
        isPolicyPrivacyFlow: Bool = false,
        target: Any? = nil,
        action: Selector? = nil
    ) {
        super.init(frame: .zero)
        
        configureStackView(isPolicyPrivacyFlow: isPolicyPrivacyFlow)
        layoutTitleLabel(isPolicyPrivacyFlow: isPolicyPrivacyFlow)
        setNavigationTitle(title)
        
        if let target = target, let action = action {
            addTargetToBackButton(target, action: action)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureStackView(isPolicyPrivacyFlow: Bool) {
        axis = .horizontal
        alignment = isPolicyPrivacyFlow ? .fill : .center
        distribution = .fill
        spacing = 0
        translatesAutoresizingMaskIntoConstraints = false
        
        [backButton, navigationTitleView].forEach {
            addArrangedSubview($0)
        }
    }

    private func layoutTitleLabel(isPolicyPrivacyFlow: Bool) {
        navigationTitleView.addSubview(navigationTitleLabel)
        
        let topAnchorConstraint: NSLayoutConstraint = {
            if isPolicyPrivacyFlow {
                return navigationTitleLabel.topAnchor.constraint(equalTo: navigationTitleView.topAnchor)
            } else {
                return navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationTitleView.topAnchor)
            }
        }()

        NSLayoutConstraint.activate([
            topAnchorConstraint,
            navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationTitleView.leadingAnchor),
            navigationTitleLabel.trailingAnchor.constraint(equalTo: navigationTitleView.trailingAnchor)
        ])
    }

    // MARK: - Private Methods

    private func addTargetToBackButton(_ target: Any?, action: Selector) {
        backButton.addTarget(target, action: action, for: .touchUpInside)
    }

    private func setNavigationTitle(_ title: String) {
        navigationTitleLabel.text = title
    }
}
