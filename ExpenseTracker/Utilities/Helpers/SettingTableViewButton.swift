import UIKit

final class SettingTableViewButton: UIButton {
    
    // MARK: - UI
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.text = SettingsLabel.logout.rawValue
        label.textColor = .etErrors
        label.applyTextStyle(.body, textStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    private let separator: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.etSeparators
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
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
    
    
//    func hideSeparator() {
//        separator.isHidden = true
//    }
//    
//    func showSeparator() {
//        separator.isHidden = false
//    }
    
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
            
            buttonLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            buttonLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            buttonLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
//            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
//            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
//            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
//            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
