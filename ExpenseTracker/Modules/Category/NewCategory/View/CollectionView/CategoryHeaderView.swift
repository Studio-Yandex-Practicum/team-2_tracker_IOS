import UIKit

final class CategoryHeaderView: UICollectionReusableView {
    
    static let identifier = String(describing: CategoryHeaderView.self)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = CategoryLabel.chooseIcon.rawValue
        label.applyTextStyle(.body, textStyle: .body)
        label.textColor = .etPrimaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
