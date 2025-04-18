import UIKit

final class MainButton: UIButton {
    
    init(title: String,
         backgroundColor: UIColor = .etInactive,
         titleColor: UIColor = .etButtonLabel,
         cornerRadius: CGFloat = 12,
         style: AppTextStyle = .button,
         textStyle: UIFont.TextStyle = .body,
         numberOfLines: Int = 1,
         textAlignment: NSTextAlignment = .center) {
        
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        setTitleColor(titleColor, for: .normal)
        layer.cornerRadius = cornerRadius
        titleLabel?.applyTextStyle(style, textStyle: textStyle)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.numberOfLines = 1
        titleLabel?.textAlignment = .center
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
