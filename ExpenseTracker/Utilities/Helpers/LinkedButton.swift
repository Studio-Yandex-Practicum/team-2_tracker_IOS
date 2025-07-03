import UIKit

final class LinkedButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.etAccent, for: .normal)
        titleLabel?.text = title
        titleLabel?.applyTextStyle(.tag, textStyle: .callout)
        titleLabel?.numberOfLines = 0
        titleLabel?.sizeToFit()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
