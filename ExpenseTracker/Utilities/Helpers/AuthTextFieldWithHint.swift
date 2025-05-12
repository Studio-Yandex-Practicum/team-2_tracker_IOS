import UIKit

final class AuthTextFieldWithHint: UIView {
    
    let textField: AuthTextField
    private let hintLabel: TextFieldHint
    private let isHintHidden: Bool
    
    init(textField: AuthTextField, hintLabel: TextFieldHint = TextFieldHint(hintText: ""), isHintHidden: Bool = false) {
        self.textField = textField
        self.hintLabel = hintLabel
        self.isHintHidden = isHintHidden
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setErrorHint(with text: String) {
        hintLabel.isHidden = false
        hintLabel.text = text
        hintLabel.textColor = .etErrors
        hintLabel.applyTextStyle(.caption, textStyle: .caption1)
        textField.layer.borderColor = UIColor.etErrors.cgColor
    }
    
    func setupHint(with text: String) {
        hintLabel.isHidden = false
        hintLabel.text = text
        hintLabel.textColor = .etInactive
        hintLabel.applyTextStyle(.caption, textStyle: .caption1)
        textField.layer.borderColor = UIColor.clear.cgColor
    }
    
    func removeHint() {
        hintLabel.isHidden = true
        hintLabel.text = ""
        hintLabel.applyTextStyle(.caption, textStyle: .caption1)
        textField.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func setupViews() {
        hintLabel.isHidden = isHintHidden
        addSubview(textField)
        addSubview(hintLabel)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 1),
            hintLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hintLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hintLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
