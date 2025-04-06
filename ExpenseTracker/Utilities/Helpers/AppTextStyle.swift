import UIKit

/// Перечисление текстовых стилей приложения с поддержкой:
/// - Кастомных шрифтов
/// - Адаптивного межстрочного интервала
/// - Кернинга (межбуквенного расстояния)
enum AppTextStyle {
    case h1
    case h2
    case body
    case button
    case secondary
    case numbers
    
    var font: UIFont {
        let fontName: String
        let size: CGFloat
        
        switch self {
        case .h1:
            fontName = "Manrope-SemiBold"
            size = 20
        case .h2:
            fontName = "Manrope-Medium"
            size = 16
        case .body:
            fontName = "Manrope-Regular"
            size = 16
        case .button:
            fontName = "Manrope-SemiBold"
            size = 16
        case .secondary:
            fontName = "Manrope-Regular"
            size = 14
        case .numbers:
            fontName = "Manrope-Bold"
            size = 36
        }
        
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .h1: return 28
        case .h2: return 24
        case .body: return 24
        case .button: return 24
        case .secondary: return 20
        case .numbers: return 38
        }
    }
    
    var letterSpacing: CGFloat {
        switch self {
        case .h1: return -0.2
        case .numbers: return -0.4
        default: return 0
        }
    }
}
