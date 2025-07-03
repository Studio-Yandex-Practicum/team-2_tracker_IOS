import Foundation

extension Decimal {
    func formattedAsRuble() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₽"
        formatter.currencyDecimalSeparator = ","
        formatter.currencyGroupingSeparator = " "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU") // Локаль РФ

        return formatter.string(from: self as NSDecimalNumber) ?? ""
    }
}
