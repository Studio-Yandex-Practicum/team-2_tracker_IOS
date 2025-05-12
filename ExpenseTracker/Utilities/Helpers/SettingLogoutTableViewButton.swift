import UIKit

final class SettingLogoutTableViewButton: UIButton {
    
    // MARK: - UI
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.text = SettingsLabel.logout.rawValue
        label.textColor = .etErrors
        label.applyTextStyle(.body, textStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    
    // MARK: - Layout
    
    private func setupUI() {
        backgroundColor = .etCardsToggled
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonLabel)
  //      addSubview(separator)
        
        NSLayoutConstraint.activate([
            
            buttonLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
