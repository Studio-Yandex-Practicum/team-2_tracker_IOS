import UIKit

final class MoneyTextField: UITextField {
    
    // MARK: - Private Properties
    
    private lazy var toggleButton = UIButton(type: .custom)
    private let paddingView = UIView(frame: CGRect(
        x: 0,
        y: 0,
        width: Constants.paddingWidth,
        height: Constants.defaultHeight
    ))
    
    
    // MARK: - Init
    
    init(placeholder: String,
         backgroundColor: UIColor = .etCardsToggled,
         titleColor: UIColor = .etCards,
         cornerRadius: CGFloat = Constants.defaultCornerRadius,
         borderColor: UIColor = .clear,
         borderWidth: CGFloat = 1) {
        
        super.init(frame: .zero)
        
        setupTextField(placeholder: placeholder,
                       backgroundColor: backgroundColor,
                       titleColor: titleColor,
                       borderColor: borderColor,
                       borderWidth: borderWidth)
        
        //        if !isEyeIconHidden {
        //            setupToggleButton(name: String)
        //        }
        
        //        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    func setupTextField(placeholder: String,
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
    
    func setupToggleButton(_ name: String) {
        
        let moneyImage = UIImage(named: name)?.withTintColor(.etPrimaryLabel)
        toggleButton.setImage(moneyImage, for: .normal)
        
        toggleButton.tintColor = .etPrimaryLabel
        toggleButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        rightView = toggleButton
        rightViewMode = .always
    }
    
    
    
    // MARK: - UITextFieldDelegate
    
    //extension AuthTextField: UITextFieldDelegate {
    //    private func textFieldDidBeginEditing(_ textField: UITextField) {
    //        layer.borderColor = UIColor.etAccent.cgColor
    //    }
    //
    //    private func textFieldDidEndEditing(_ textField: UITextField) {
    //        layer.borderColor = UIColor.clear.cgColor
    //    }
    //}
    
    // MARK: - Constants
    
    private enum Constants {
        static let defaultCornerRadius: CGFloat = 12
        static let paddingWidth: CGFloat = 16
        static let defaultHeight: CGFloat = 50
    }
    
}
