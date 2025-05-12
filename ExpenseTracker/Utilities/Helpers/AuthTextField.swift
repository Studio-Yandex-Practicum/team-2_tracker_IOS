import UIKit

final class AuthTextField: UITextField {
    
    // MARK: - Private Properties
    
    private lazy var toggleButton = UIButton(type: .custom)
    private var isEyeIconHidden: Bool = true
    private let paddingView = UIView(frame: CGRect(
        x: 0,
        y: 0,
        width: Constants.paddingWidth,
        height: Constants.defaultHeight
    ))
    
    private let textFieldHintLabel: TextFieldHint = {
        let label = TextFieldHint(hintText: AuthValidator.ValidationError.invalidPassword.rawValue, color: .etSecondaryLabel)
        return label
    }()

    // MARK: - Init
    
    init(placeholder: String,
         isEyeIconHidden: Bool = true,
         backgroundColor: UIColor = .etCardsToggled,
         titleColor: UIColor = .etCards, 
         cornerRadius: CGFloat = Constants.defaultCornerRadius,
         borderColor: UIColor = .clear,
         borderWidth: CGFloat = 1) {
        
        super.init(frame: .zero)
        self.isEyeIconHidden = isEyeIconHidden
        
        setupTextField(placeholder: placeholder,
                       backgroundColor: backgroundColor,
                       titleColor: titleColor,
                       borderColor: borderColor,
                       borderWidth: borderWidth)
        
        if !isEyeIconHidden {
            setupToggleButton()
        }
        
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    
    // Позволяет добавить внутренний отступ для иконки справа
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 48, y: 0, width: 40, height: bounds.height)
    }

    // MARK: - Setup Methods
    
    private func setupTextField(placeholder: String,
                                backgroundColor: UIColor,
                                titleColor: UIColor,
                                borderColor: UIColor,
                                borderWidth: CGFloat) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.etSecondaryLabel]
        )
        
        self.backgroundColor = backgroundColor
        font = AppTextStyle.body.font
        textColor = titleColor
        layer.cornerRadius = Constants.defaultCornerRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        leftView = paddingView
        leftViewMode = .always
        textContentType = .oneTimeCode
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    private func setupToggleButton() {
        isSecureTextEntry = true
        
        let eyeImage = UIImage(named: Asset.Icon.eyeOff.rawValue)?.withTintColor(.etPrimaryLabel)
        toggleButton.setImage(eyeImage, for: .normal)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        toggleButton.tintColor = .etPrimaryLabel
        
        rightView = toggleButton
        rightViewMode = .always
    }

    // MARK: - Actions
    
    @objc
    private func togglePasswordVisibility() {
        let imageName = isSecureTextEntry ? Asset.Icon.eyeOn.rawValue : Asset.Icon.eyeOff.rawValue
        let image = UIImage(named: imageName)?.withTintColor(.etPrimaryLabel)
        toggleButton.setImage(image, for: .normal)
        isSecureTextEntry.toggle()
    }
}

// MARK: - UITextFieldDelegate

extension AuthTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.etAccent.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.clear.cgColor
    }
}

// MARK: - Constants

private enum Constants {
    static let defaultCornerRadius: CGFloat = 12
    static let paddingWidth: CGFloat = 16
    static let defaultHeight: CGFloat = 50
}
