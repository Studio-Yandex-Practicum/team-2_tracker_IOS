import UIKit

class MainButton: UIButton {
    
    init(title: String,
         backgroundColor: UIColor = .etAccent,
         titleColor: UIColor = .etButtonLabel,
         cornerRadius: CGFloat = 12,
         style: AppTextStyle = .button,
         textStyle: UIFont.TextStyle = .body,
         numberOfLines: Int = 1,
         textAlignment: NSTextAlignment = .center) {
        
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        self.setTitleColor(titleColor, for: .normal)
        self.layer.cornerRadius = cornerRadius
        self.titleLabel?.applyTextStyle(style, textStyle: textStyle)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
