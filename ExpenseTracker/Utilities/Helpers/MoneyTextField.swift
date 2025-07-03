import UIKit

protocol MoneyTextFieldDelegate: AnyObject {
    func updateButtonState()
}

final class MoneyTextField: UITextField {
    
    weak var moneyTextFieldDelegate: MoneyTextFieldDelegate?
    
    // MARK: - Private Properties
    
    private lazy var toggleButton = UIButton(type: .custom)
    private let paddingView = UIView(frame: CGRect(
        x: 0,
        y: 0,
        width: Constants.paddingWidth,
        height: Constants.defaultHeight
    ))
    
    var isMoreThanZero: Bool = false
    
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
        self.delegate = self
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
    
    // MARK: - Constants
    
    private enum Constants {
        static let defaultCornerRadius: CGFloat = 12
        static let paddingWidth: CGFloat = 16
        static let defaultHeight: CGFloat = 50
    }
}

extension MoneyTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        // Обработка удаления
        if string.isEmpty {
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            textField.text = newText
            moneyTextFieldDelegate?.updateButtonState()
            return false
        }
        
        if string.first == "," && currentText.isEmpty {
            return false
        }
        
        // Проверяем, что вводится только одна запятая
        if string == "," {
            if currentText.contains(",") {
                return false // Не позволяем ввести вторую запятую
            }
            return true
        }
        
        // Проверяем количество знаков после запятой
        if let commaIndex = currentText.firstIndex(of: ",") {
            let decimalPart = currentText[commaIndex...].dropFirst()
            if decimalPart.count >= 2 && range.location > commaIndex.utf16Offset(in: currentText) {
                return false // Не позволяем ввести больше 2 знаков после запятой
            }
        }
        
        // Проверяем, что вводится только цифра
        if !string.isEmpty && !string.allSatisfy({ $0.isNumber }) {
            return false
        }
        
        if string.first == "0" && currentText.isEmpty {
            return false
        }
   
        // Формируем новый текст
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Форматируем целую часть числа
        let components = updatedText.components(separatedBy: ",")
        if let integerPart = components.first {
            let formattedInteger = formatCurrency(integerPart)
            if components.count > 1 {
                textField.text = formattedInteger + "," + components[1]
            } else {
                textField.text = formattedInteger
            }
        }
        moneyTextFieldDelegate?.updateButtonState()
        
        return false
    }
    
    private func formatCurrency(_ number: String) -> String {
        // Убираем все пробелы перед форматированием
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        
        var formatted = ""
        var count = 0
        
        // Разбиваем строку на массив символов
        for char in cleanNumber.reversed() {
            if count == 3 {
                formatted.append(" ")
                count = 0
            }
            formatted.append(char)
            count += 1
        }
        
        // Возвращаем отформатированное число
        return String(formatted.reversed())
    }
}
