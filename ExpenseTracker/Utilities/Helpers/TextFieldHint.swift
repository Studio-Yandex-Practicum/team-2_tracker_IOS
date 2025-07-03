import UIKit

final class TextFieldHint: UILabel {
    
    init(hintText: String, color: UIColor? = UIColor.etSecondaryLabel) {
        super.init(frame: .zero)
        
        numberOfLines = 0
        setContentCompressionResistancePriority(.required, for: .horizontal)
        text = hintText
        textColor = color
        applyTextStyle(.caption, textStyle: .caption1)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
