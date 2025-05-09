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
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₽"
        formatter.currencyDecimalSeparator = ","
        formatter.currencyGroupingSeparator = " "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU") // Локаль РФ
        
        return formatter.string(from: expense as NSNumber  ) ?? ""
    }
}
