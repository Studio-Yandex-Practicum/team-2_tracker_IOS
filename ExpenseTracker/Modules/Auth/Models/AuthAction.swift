import Foundation

enum AuthAction: String {
    
    case auth = "Авторизация"
    case login = "Логин"
    case password = "Пароль"
    case repeatPassword = "Повторите пароль"
    case mail = "Почта"
    case areFirstInApp = "Впервые в приложении?"
    case registration = "Регистрация"
    case registrationPrivacyPolicy = "Нажимая кнопку, вы соглашаетесь с"
    case privacyPolicy = "Политика конфиденциальности и обработки персональных данных"
    case passwordRecovery = "Восстановить пароль"
}
