//
//  ExpensesTableCell.swift
//  ExpenseTracker
//
//  Created by Ольга Чушева on 09.04.2025.
//

import UIKit

final class ExpensesTableCell: UITableViewCell {
    
    var expenses: Decimal = 0
    var currency = Currency.ruble.rawValue
    
    private lazy var backView: UIView = {
        let backView = UIView()
        backView.backgroundColor = .etCardsToggled
        backView.translatesAutoresizingMaskIntoConstraints = false
        return backView
    }()
    
    private lazy var expenceView: UIView = {
        let expenceView = UIView()
        expenceView.backgroundColor = .etIconsBG
        expenceView.layer.cornerRadius = 16
        expenceView.translatesAutoresizingMaskIntoConstraints = false
        return expenceView
    }()
    
    private lazy var expenceImage: UIImageView = {
        let expenceImage = UIImageView()
        expenceImage.image = UIImage(named: Asset.Icon.cafe.rawValue)?.withTintColor(.etButtonLabel) // будет меняться
        expenceImage.translatesAutoresizingMaskIntoConstraints = false
        return expenceImage
    }()
    
     lazy var categoryMoney: UILabel = {
        let labelMoney = UILabel()
        labelMoney.text = "Категория" // переменная
        labelMoney.textColor = .etPrimaryLabel
        labelMoney.font = AppTextStyle.body.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        return labelMoney
    }()
    
     lazy var noteMoney: UILabel = {
        let labelMoney = UILabel()
        labelMoney.text = "Очень очень очень очень длинное примечание" // переменная
        labelMoney.textColor = .etSecondaryLabel
//        labelMoney.font = AppTextStyle.secondary.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        return labelMoney
    }()
    
     lazy var labelMoneyCash: UILabel = {
        let labelMoney = UILabel()
        labelMoney.text = ""
        labelMoney.textColor = .etPrimaryLabel
        labelMoney.font = AppTextStyle.body.font
        labelMoney.translatesAutoresizingMaskIntoConstraints = false
        return labelMoney
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    func setupCell() {
        expenceView.addSubview(expenceImage)
        contentView.addSubview(backView)
        backView.addSubview(expenceView)
        backView.addSubview(categoryMoney)
        backView.addSubview(noteMoney)
        backView.addSubview(labelMoneyCash)
        
        NSLayoutConstraint.activate([
            
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            expenceView.heightAnchor.constraint(equalToConstant: 32),
            expenceView.widthAnchor.constraint(equalToConstant: 32),
            expenceView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            expenceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            expenceImage.centerYAnchor.constraint(equalTo: expenceView.centerYAnchor),
            expenceImage.centerXAnchor.constraint(equalTo: expenceView.centerXAnchor),
            
            noteMoney.text == "" ?
            categoryMoney.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18) :
            categoryMoney.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            categoryMoney.leadingAnchor.constraint(equalTo: expenceImage.trailingAnchor, constant: 16),
            categoryMoney.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -68),
            
            noteMoney.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            noteMoney.leadingAnchor.constraint(equalTo: expenceImage.trailingAnchor, constant: 16),
            noteMoney.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -48),
            
            labelMoneyCash.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            labelMoneyCash.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
