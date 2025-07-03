import UIKit

final class MainTextField: UITextField {
    
    // MARK: - Private Properties
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: Asset.Icon.close.rawValue)
        button.setImage(image?.withTintColor(.etPrimaryLabel), for: .normal)
        button.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        return button
    }()
    
    private let paddingView = UIView(frame: CGRect(
        x: 0,
        y: 0,
        width: Constants.paddingWidth,
        height: Constants.defaultHeight
    ))
    
    // MARK: - Init
    
    init(placeholder: String? = nil) {
        super.init(frame: .zero)
        
        delegate = self
        setupPlaceholder(with: placeholder)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    
    // Позволяет добавить внутренний отступ для иконки справа
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 48, y: 0, width: 44, height: bounds.height)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        font = AppTextStyle.body.font
        backgroundColor = .etCardsToggled
        textColor = .etCards
        
        layer.cornerRadius = Constants.defaultCornerRadius
        layer.borderWidth = Constants.defaultBorderWidth
        layer.borderColor = UIColor.clear.cgColor
        
        leftView = paddingView
        leftViewMode = .always
        rightView = clearButton
        rightViewMode = .whileEditing
        textContentType = .oneTimeCode
        
        heightAnchor.constraint(equalToConstant: 48).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupPlaceholder(with placeholder: String? = nil) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func clearText() {
        self.text = ""
        sendActions(for: .editingChanged)
    }
    
    @objc
    private func textDidChange() {
        clearButton.isHidden = text?.isEmpty ?? true
    }
}

// MARK: - UITextFieldDelegate

extension MainTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.etAccent.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.clear.cgColor
    }
}

private enum Constants {
    static let defaultCornerRadius: CGFloat = 12
    static let defaultBorderWidth: CGFloat = 1
    static let paddingWidth: CGFloat = 16
    static let defaultHeight: CGFloat = 50
}
