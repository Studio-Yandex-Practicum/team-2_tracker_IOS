import Foundation

enum AuthValidator {
    
    enum ValidationError: String {
        case authFailed = "Неверный e-mail или пароль"
        case invalidEmail = "Некорректный e-mail"
        case alreadyRegistered = "Пользователь с таким e-mail уже зарегистрирован"
        case emailAlreadyExists = "Введите адрес, указанный при регистрации. На него придёт код для восстановления"
        case invalidPassword = "Пароль должен содержать не менее 6 символов"
        case passwordsDoNotMatch = "Пароли не совпадают"
    }
    
    // Валидация email
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
    
    // Валидация пароля
    static func isValidPassword(_ password: String) -> Bool {
        let minLength = password.count >= 6
        return minLength
    }

    // Проверка на соответствие паролей
    static func doPasswordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
    
    static func validate(email: String, password: String, confirmPassword: String) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if !isValidEmail(email) {
            errors.append(.invalidEmail)
        }
        
        if !isValidPassword(password) {
            errors.append(.invalidPassword)
        }
        
        if !doPasswordsMatch(password, confirmPassword) {
            errors.append(.passwordsDoNotMatch)
        }
        return errors
    }
}
