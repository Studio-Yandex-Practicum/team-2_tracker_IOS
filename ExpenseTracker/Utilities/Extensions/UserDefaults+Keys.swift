import Foundation

extension UserDefaults {
    
    enum Keys: String {
        case isLoggedIn
    }
    
    // Свойства для удобного доступа
    static var isLoggedIn: Bool {
        get {
            return standard.bool(forKey: Keys.isLoggedIn.rawValue)
        }
        set {
            standard.set(newValue, forKey: Keys.isLoggedIn.rawValue)
        }
    }
}
