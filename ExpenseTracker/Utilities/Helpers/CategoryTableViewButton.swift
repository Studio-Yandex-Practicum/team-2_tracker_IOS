import UIKit

final class CategoryTableViewButton: UIButton {
    
    // MARK: - UI
    
    private let addIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Asset.Icon.btnAdd.rawValue)?.withTintColor(.etIcons)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let iconButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .etAccent
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.text = CategoryLabel.createCategory.rawValue
        label.textColor = .etPrimaryLabel
        label.applyTextStyle(.body, textStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.etSeparators
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    init(title: String, isShownButton: Bool) {
        super.init(frame: .zero)
        buttonLabel.text = title
        buttonLabel.applyTextStyle(.body, textStyle: .body)
        setupUI()
        
        [addIcon, iconButton].forEach {
            $0.isHidden = !isShownButton
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Configuration
    
    func addTargetToIcon(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        iconButton.addTarget(target, action: action, for: controlEvents)
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        backgroundColor = .etCardsToggled
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconButton)
        iconButton.addSubview(addIcon)
        addSubview(buttonLabel)
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            iconButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconButton.widthAnchor.constraint(equalToConstant: 32),
            iconButton.heightAnchor.constraint(equalToConstant: 32),
            
            addIcon.widthAnchor.constraint(equalToConstant: 19),
            addIcon.heightAnchor.constraint(equalToConstant: 19),
            addIcon.centerXAnchor.constraint(equalTo: iconButton.centerXAnchor),
            addIcon.centerYAnchor.constraint(equalTo: iconButton.centerYAnchor),
            
            buttonLabel.leadingAnchor.constraint(equalTo: iconButton.trailingAnchor, constant: 8),
            buttonLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
