import UIKit

final class TimeButton: UIButton {
    
    init(title: String,
         backgroundColor: UIColor = .etCardsToggled,
         titleColor: UIColor = .etCards,
         cornerRadius: CGFloat = 6,
         style: AppTextStyle = .button,
         textStyle: UIFont.TextStyle = .body,
         numberOfLines: Int = 1,
         textAlignment: NSTextAlignment = .center) {
        
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        setTitleColor(titleColor, for: .normal)
        layer.cornerRadius = cornerRadius
        titleLabel?.applyTextStyle(.tag, textStyle: textStyle)
        titleLabel?.numberOfLines = 1
        titleLabel?.textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
