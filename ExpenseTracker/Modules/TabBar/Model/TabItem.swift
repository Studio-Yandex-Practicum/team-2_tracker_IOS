import UIKit

enum TabItem: CaseIterable {
    
    case analytics
    case expenses
    case settings
    
    var title: String {
        switch self {
        case .analytics: return "Аналитика"
        case .expenses: return "Расходы"
        case .settings: return "Настройки"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .analytics: return UIImage(named: "chart")
        case .expenses: return UIImage(named: "list")
        case .settings: return UIImage(named: "settings")
        }
    }
}
