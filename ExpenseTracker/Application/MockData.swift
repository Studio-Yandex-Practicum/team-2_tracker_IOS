import Foundation

var expensesMockData: [Expense] = [
    Expense(id: UUID(), expense: 5500.87, category: Category(id: UUID(), name: "Продукты", icon: .groceries), date: Date(timeIntervalSinceNow: 0), note: "Примечание"),
    Expense(id: UUID(), expense: 3500, category: Category(id: UUID(), name: "Продукты", icon: .groceries), date: Date(timeIntervalSinceNow: -86400), note: ""),
    Expense(id: UUID(), expense: 1000, category: Category(id: UUID(), name: "Дом", icon: .home), date: Date(timeIntervalSinceNow: -86400), note: "Примечание"),
    
    Expense(id: UUID(), expense: 1000, category: Category(id: UUID(), name: "Хобби", icon: .hobby), date: Date(timeIntervalSinceNow: -864065), note: "Примечание"),
    Expense(id: UUID(), expense: 3500, category: Category(id: UUID(), name: "Транспорт", icon: .transport), date: Date(timeIntervalSinceNow: -86400), note: ""),
    Expense(id: UUID(), expense: 5500, category: Category(id: UUID(), name: "Здоровье", icon: .health), date: Date(timeIntervalSinceNow: -5643465), note: "Примечание"),
    Expense(id: UUID(), expense: 1000, category: Category(id: UUID(), name: "Образование", icon: .education), date: Date(timeIntervalSinceNow: -86400), note: ""),
    
    Expense(id: UUID(), expense: 1500, category: Category(id: UUID(), name: "Продукты", icon: .groceries), date: Date(timeIntervalSinceNow: -86400 * 5), note: ""),
    Expense(id: UUID(), expense: 3500, category: Category(id: UUID(), name: "Кафе", icon: .cafe), date: Date(timeIntervalSinceNow: -86400 * 5), note: "Примечание"),
    
    Expense(id: UUID(), expense: 4000, category: Category(id: UUID(), name: "Семья", icon: .family), date: Date(timeIntervalSinceNow: -87654544), note: "Примечание")
]
