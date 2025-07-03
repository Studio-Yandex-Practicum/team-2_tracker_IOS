import UIKit

final class CategoryIconCell: UICollectionViewCell {
    
    static let identifier = String(describing: CategoryIconCell.self)

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.layer.cornerRadius = 22
        contentView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with iconName: String, selected: Bool) {
        let iconColor: UIColor = selected ? .etButtonLabel : .etAccent
        let image = UIImage(named: iconName)?.withTintColor(iconColor)
        iconImageView.image = image
        contentView.backgroundColor = selected ? .etAccent : .clear
    }
}
