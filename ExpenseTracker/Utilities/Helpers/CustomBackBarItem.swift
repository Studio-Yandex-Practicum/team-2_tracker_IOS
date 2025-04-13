import UIKit

final class CustomBackBarItem: UIStackView {
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Asset.Icon.arrowBack.rawValue)?.withTintColor(.etPrimaryLabel), for: .normal)
        button.contentHuggingPriority(for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .etPrimaryLabel
        label.text = AuthAction.registration.rawValue
        label.applyTextStyle(.h1, textStyle: .title1)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        axis = .horizontal
        distribution = .fillProportionally
        translatesAutoresizingMaskIntoConstraints = false
        
        addArrangedSubview(backButton)
        addArrangedSubview(navigationTitleLabel)
    }
    
    func addTargetToBackButton(_ target: Any?, action: Selector) {
        backButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
