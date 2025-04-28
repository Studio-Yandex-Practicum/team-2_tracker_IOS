import UIKit

class ExpensesTableHeaders: UITableViewHeaderFooterView {
   static let identifire = "ExpensesTableHeaders"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTextStyle.button.font
        label.textColor = .etPrimaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}



