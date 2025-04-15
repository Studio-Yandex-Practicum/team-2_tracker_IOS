import UIKit

final class CalendarButton: UIButton {
    
    init(
        backgroundColor: UIColor = .etBackground) {
 
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        setBackgroundImage(UIImage(named: Asset.Icon.calendar.rawValue)?.withTintColor(.etCards), for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
