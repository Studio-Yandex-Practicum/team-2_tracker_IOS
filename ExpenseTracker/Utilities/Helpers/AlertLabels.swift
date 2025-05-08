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

        static let interruptPasswordRecovery = "Вы уверены, что хотите прервать процесс восстановления пароля?"
        static let interruptRegistration = "У вас есть несохраненные изменения. Вы уверены, что хотите выйти?"
        static let confirmDelete = "Уверены, что хотите удалить?"
        static let error = "Произошла ошибка. Пожалуйста, попробуйте еще раз."
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
