import UIKit

final class AuthTextField: UITextField {
    
    // MARK: - Private Properties
    
    private lazy var toggleButton = UIButton(type: .custom)
    private let paddingView = UIView(frame: CGRect(
        x: 0,
        y: 0,
        width: Constants.paddingWidth,
        height: Constants.defaultHeight
    ))
    
    private var isEyeIconHidden: Bool = true

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

    // MARK: - Setup Methods
    
    private func setupTextField(placeholder: String,
                                backgroundColor: UIColor,
                                titleColor: UIColor,
                                borderColor: UIColor,
                                borderWidth: CGFloat) {
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.etSecondaryLabel]
        )
        
        self.backgroundColor = backgroundColor
        self.font = AppTextStyle.body.font
        self.textColor = titleColor
        self.layer.cornerRadius = Constants.defaultCornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    private func setupToggleButton() {
        isSecureTextEntry = true
        
        let eyeImage = UIImage(named: Asset.Icon.eyeOff.rawValue)?.withTintColor(.etPrimaryLabel)
        toggleButton.setImage(eyeImage, for: .normal)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        toggleButton.tintColor = .etPrimaryLabel
        toggleButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
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
