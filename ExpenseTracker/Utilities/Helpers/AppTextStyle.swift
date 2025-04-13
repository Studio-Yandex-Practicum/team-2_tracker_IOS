import UIKit

/// Перечисление текстовых стилей приложения с поддержкой:
/// - Кастомных шрифтов
/// - Адаптивного межстрочного интервала
/// - Кернинга (межбуквенного расстояния)
enum AppTextStyle {
    case largeTitle
    case h1
    case h2
    case body
    case caption
    case button
    case tag
    case numbers
    
    var font: UIFont {
        let fontName: String
        let size: CGFloat
        
        switch self {
        case .largeTitle:
            fontName = "Manrope-Bold"
            size = 24
        case .h1:
            fontName = "Manrope-SemiBold"
            size = 20
        case .h2:
            fontName = "Manrope-Medium"
            size = 16
        case .caption:
            fontName = "Manrope-Regular"
            size = 14
        case .body:
            fontName = "Manrope-Regular"
            size = 16
        case .button:
            fontName = "Manrope-SemiBold"
            size = 16
        case .tag:
            fontName = "Manrope-SemiBold"
            size = 14
        case .numbers:
            fontName = "Manrope-Bold"
            size = 36
        }
        
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .largeTitle: return 32
        case .h1: return 28
        case .h2, .body: return 24
        case .button: return 24
        case .caption, .tag: return 20
        case .numbers: return 38
        }
    }
    
    var letterSpacing: CGFloat {
        switch self {
        case .h1: return -0.2
        case .largeTitle, .numbers: return -0.4
        default: return 0
        }
    }
}
