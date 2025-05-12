import Foundation

struct Expense {
    
    let id: UUID
    let expense: Decimal
    let category: Category
    let date: Date
    let note: String
   
    var formattedDate: String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM" // Здесь задается формат даты
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date) 
    }
    
    var formattedAsRuble: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0 // Минимум 0 знаков после запятой
        numberFormatter.maximumFractionDigits = 2 // Максимум 2 знака после запятой
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = ","
        
        if let formattedAmount = numberFormatter.string(from: NSDecimalNumber(decimal: expense)) {
            // Если сумма заканчивается на ",00", убираем копейки
            if formattedAmount.hasSuffix(",00") {
                return String(formattedAmount.dropLast(3)) + " " + Currency.ruble.rawValue
            }
            return formattedAmount + " " + Currency.ruble.rawValue
        }
        return "0 " + Currency.ruble.rawValue
    }
}
