import UIKit

final class FiltersButton: UIButton {
    
    init(title: String,
         backgroundColor: UIColor = .etBackground,
         titleColor: UIColor = .etPrimaryLabel,
         style: AppTextStyle = .body,
         textStyle: UIFont.TextStyle = .body,
         imagePadding: Int = 10,
         image: UIImage) {
        super.init(frame: .zero)
        tintColor = .etAccent
        setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        setTitleColor(titleColor, for: .normal)
        titleLabel?.applyTextStyle(style, textStyle: textStyle)
        self.setImage(image, for: .normal)
        var configuration = self.configuration ?? UIButton.Configuration.plain()
        configuration.imagePadding = 10
        self.configuration = configuration
        frame.size = .init(width: 200, height: 28)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
