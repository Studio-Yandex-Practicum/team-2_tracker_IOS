//
//  ExpensesTableCell.swift
//  ExpenseTracker
//
//  Created by Ольга Чушева on 09.04.2025.
//

import UIKit

final class ExpensesTableCell: UITableViewCell {
    
    // MARK: - Properties
    
    var expenses: Decimal = 0
    var currency = Currency.ruble.rawValue
    
    // MARK: - UI Components
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .etCardsToggled
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var expenceView: UIView = {
        let view = UIView()
        view.backgroundColor = .etIconsBG
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var expenceImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Asset.Icon.cafe.rawValue)?.withTintColor(.etButtonLabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var categoryMoney: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = .etPrimaryLabel
        label.font = AppTextStyle.body.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var noteMoney: UILabel = {
        let label = UILabel()
        label.text = "Очень очень очень очень длинное примечание"
        label.textColor = .etSecondaryLabel
        label.font = AppTextStyle.caption.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var labelMoneyCash: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .etPrimaryLabel
        label.font = AppTextStyle.body.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let customSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .etSeparators
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        // Добавляем основные view
        contentView.addSubview(backView)
        backView.addSubview(expenceView)
        backView.addSubview(labelsStack)
        backView.addSubview(labelMoneyCash)
        backView.addSubview(customSeparator)
        
        // Настраиваем иконку
        expenceView.addSubview(expenceImage)
        
        // Настраиваем стек с лейблами
        labelsStack.addArrangedSubview(categoryMoney)
        labelsStack.addArrangedSubview(noteMoney)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // BackView constraints
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // ExpenceView constraints
            expenceView.heightAnchor.constraint(equalToConstant: 32),
            expenceView.widthAnchor.constraint(equalToConstant: 32),
            expenceView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            expenceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // ExpenceImage constraints
            expenceImage.centerYAnchor.constraint(equalTo: expenceView.centerYAnchor),
            expenceImage.centerXAnchor.constraint(equalTo: expenceView.centerXAnchor),
            expenceImage.widthAnchor.constraint(equalToConstant: 20),
            expenceImage.heightAnchor.constraint(equalToConstant: 20),
            
            // LabelsStack constraints
            labelsStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsStack.leadingAnchor.constraint(equalTo: expenceView.trailingAnchor, constant: 8),
            labelsStack.trailingAnchor.constraint(equalTo: labelMoneyCash.leadingAnchor, constant: -16),
            
            // LabelMoneyCash constraints
            labelMoneyCash.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            labelMoneyCash.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16),
            
            customSeparator.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            customSeparator.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            customSeparator.bottomAnchor.constraint(equalTo: backView.bottomAnchor),
            customSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with expense: Expense) {
        categoryMoney.text = expense.category
        noteMoney.text = expense.note
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = ","
        
        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: expense.expense)) {
            // Проверяем, заканчивается ли число на ",00"
            if formattedAmount.hasSuffix(",00") {
                // Убираем ",00" из строки
                let wholeNumber = String(formattedAmount.dropLast(3))
                labelMoneyCash.text = wholeNumber + " " + currency
            } else {
                labelMoneyCash.text = formattedAmount + " " + currency
            }
        }
    }
    
    func hideSeparator() {
        customSeparator.isHidden = true
    }
    
    func showSeparator() {
        customSeparator.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryMoney.text = nil
        noteMoney.text = nil
        labelMoneyCash.text = nil
        customSeparator.isHidden = false
    }
}
