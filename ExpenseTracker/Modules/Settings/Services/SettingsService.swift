import Foundation
import CoreData

final class SettingsService {
    
    // MARK: - Properties
    
    private let expensesViewModel: ExpensesViewModel
    
    // MARK: - Initialization
    
    init() {
        let context = CoreDataStackManager.shared.context
        self.expensesViewModel = ExpensesViewModel(context: context)
    }
    
    // MARK: - Public Methods
    
    func exportExpensesToCSV() -> Result<URL, Error> {
        // Получаем все расходы
        let expenses = expensesViewModel.getAllExpenses()
        
        // Создаем CSV строку
        var csvString = "Дата,Категория,Сумма,Описание\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        for expense in expenses {
            let date = dateFormatter.string(from: expense.date ?? Date())
            let category = expense.category?.name ?? "Без категории"
            let amount = String(format: "%.2f", expense.amount?.doubleValue ?? 0)
            let note = expense.note ?? ""
            
            csvString.append("\(date),\(category),\(amount),\(note)\n")
        }
        
        // Создаем временный файл
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "expenses_\(Date().timeIntervalSince1970).csv"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return .success(fileURL)
        } catch {
            return .failure(error)
        }
    }
} 