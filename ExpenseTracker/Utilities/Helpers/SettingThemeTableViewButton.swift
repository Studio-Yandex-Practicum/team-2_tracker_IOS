import UIKit

enum ThemeApp {
    
    case day
    case night
    
    var swithOn: Bool {
        switch self {
        case .day:
            return false
        case .night:
            return true
        }
    }
    
    var saveButtonText: String {
        switch self {
        case .day:
            return Asset.Icon.light.rawValue
        case .night:
            return Asset.Icon.dark.rawValue
        }
    }
}

final class SettingThemeTableViewButton: UIButton {
    
    // MARK: - UI
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.text = SettingsLabel.theme.rawValue
        label.textColor = .etPrimaryLabel
        label.applyTextStyle(.body, textStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dayNighteImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: ThemeApp.day.saveButtonText)?.withTintColor(.etCards)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let buttonSwitch: UISwitch = {
        let swith = UISwitch()
        swith.isOn = ThemeApp.day.swithOn
        swith.onTintColor = .etAccent
        swith.accessibilityIgnoresInvertColors = true
        swith.isAccessibilityElement = true
        swith.translatesAutoresizingMaskIntoConstraints = false
        return swith
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.etSeparators
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    init(title: String) {
        super.init(frame: .zero)
        buttonLabel.text = title
        buttonLabel.applyTextStyle(.body, textStyle: .body)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Configuration
    
    func hideSeparator() {
        separator.isHidden = true
    }

    func showSeparator() {
        separator.isHidden = false
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        backgroundColor = .etCardsToggled
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonLabel)
        addSubview(buttonSwitch)
        addSubview(dayNighteImage)
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            
            buttonLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            buttonSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            dayNighteImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            dayNighteImage.trailingAnchor.constraint(equalTo: buttonSwitch.leadingAnchor, constant: -8),
            
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
