import Foundation

/// Глобальные лейблы для алертов в приложении
enum AlertLabels {
    
    /// Заголовки алертов
    enum Title {
        
        static let passwordRecovery = "Восстановление пароля"
        static let registration = "Регистрация"
        static let delete = "Удаление"
        static let warning = "Внимание"
    }
    
    /// Сообщения алертов
    enum Message {
        /// Сообщение для прерывания восстановления пароля
        static let interruptPasswordRecovery = "Вы уверены, что хотите прервать процесс восстановления пароля?"
        
        /// Сообщение для прерывания регистрации
        static let interruptRegistration = "У вас есть несохраненные изменения. Вы уверены, что хотите выйти?"
        
        /// Сообщение для подтверждения удаления
        static let confirmDelete = "Уверены, что хотите удалить?"
        
        /// Сообщение для ошибки
        static let error = "Произошла ошибка. Пожалуйста, попробуйте еще раз."
        
        /// Сообщение об успешной отправке письма для восстановления пароля
        static let passwordRecoveryEmailSent = "Письмо с инструкциями по восстановлению пароля отправлено на вашу почту"
        
        /// Сообщение об успешной регистрации
        static let registrationSuccess = "Регистрация успешно завершена"
    }
    
    /// Кнопки алертов
    enum Button {
        
        static let cancel = "Отмена"
        static let interrupt = "Прервать"
        static let exit = "Выйти"
        static let delete = "Удалить"
        static let confirm = "Подтвердить"
        static let ok = "ОК"
    }
} 
