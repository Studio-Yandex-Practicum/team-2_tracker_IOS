import Foundation

var expensesMockData: [Expense] = [
    Expense(id: UUID(), expense: 5500, category: "Продукты", date: Date(timeIntervalSinceNow: 0), note: "Примечание"),
    Expense(id: UUID(), expense: 3500, category: "Продукты", date: Date(timeIntervalSinceNow: 0), note: ""),
    Expense(id: UUID(), expense: 1000, category: "Дом", date: Date(timeIntervalSinceNow: 0), note: "Примечание"),
    
    Expense(id: UUID(), expense: 1000, category: "Транспорт", date: Date(timeIntervalSinceNow: -864065), note: "Примечание"),
    Expense(id: UUID(), expense: 3500, category: "Транспорт", date: Date(timeIntervalSinceNow: -23466), note: ""),
    Expense(id: UUID(), expense: 5500, category: "Здоровье", date: Date(timeIntervalSinceNow: -5643465), note: "Примечание"),
    Expense(id: UUID(), expense: 1000, category: "Дом", date: Date(timeIntervalSinceNow: -86400), note: ""),
    
    Expense(id: UUID(), expense: 1500, category: "Здоровье", date: Date(timeIntervalSinceNow: -86400 * 5), note: ""),
    Expense(id: UUID(), expense: 3500, category: "Здоровье", date: Date(timeIntervalSinceNow: -86400 * 5), note: "Примечание"),
    
    Expense(id: UUID(), expense: 4000, category: "Семья", date: Date(timeIntervalSinceNow: -87654544), note: "Примечание")
]
