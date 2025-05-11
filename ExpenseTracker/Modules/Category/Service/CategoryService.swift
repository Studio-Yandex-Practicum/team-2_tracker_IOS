import Foundation
import CoreData

final class CategoryService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        initializeBaseCategories()
    }
    
    private func initializeBaseCategories() {
        // Проверяем, есть ли уже категории в базе
        let existingCategories = fetchAllCategories()
        if !existingCategories.isEmpty {
            return // Если категории уже есть, не добавляем их снова
        }
        
        // Добавляем базовые категории из CategoryProvider
        for category in CategoryProvider.baseCategories {
            do {
                try createCategory(category)
            } catch {
                print("Error saving base category: \(error)")
            }
        }
    }
    
    func createCategory(_ category: CategoryMain) throws {
        let categoryModel = CategoryModel(context: context)
        categoryModel.id = UUID()
        categoryModel.name = category.title
        categoryModel.icon = category.icon.rawValue
        
        try context.save()
    }
    
    func fetchAllCategories() -> [CategoryModel] {
        let fetchRequest: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
} 