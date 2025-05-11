import Foundation
import CoreData
import FirebaseAuth

final class CategoryService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        initializeBaseCategories()
    }
    
    private func initializeBaseCategories() {
        // Проверяем, есть ли уже категории в базе для текущего пользователя
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
        print("Attempting to create category with name: \(category.title) and icon: \(category.icon.rawValue)")
        
        // Проверяем, существует ли уже категория с таким именем для текущего пользователя
        let fetchRequest: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND userID == %@", 
            category.title,
            Auth.auth().currentUser?.uid ?? ""
        )
        
        do {
            let existingCategories = try context.fetch(fetchRequest)
            print("Found \(existingCategories.count) existing categories with name: \(category.title)")
            
            if !existingCategories.isEmpty {
                print("Category already exists")
                throw NSError(domain: "CategoryError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Категория с таким названием уже существует"])
            }
            
            print("Creating new category")
            // Создаем новую категорию
            let categoryModel = CategoryModel(context: context)
            categoryModel.id = UUID()
            categoryModel.name = category.title
            categoryModel.icon = category.icon.rawValue
            categoryModel.userID = Auth.auth().currentUser?.uid
            
            try context.save()
            print("Category created successfully")
        } catch {
            print("Error creating category: \(error)")
            throw error
        }
    }
    
    func fetchAllCategories() -> [CategoryModel] {
        let fetchRequest: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
        
        // Добавляем предикат для фильтрации по userID
        if let currentUserID = Auth.auth().currentUser?.uid {
            fetchRequest.predicate = NSPredicate(format: "userID == %@", currentUserID)
        }
        
        do {
            let categories = try context.fetch(fetchRequest)
            print("Fetched \(categories.count) categories for userID: \(Auth.auth().currentUser?.uid ?? "nil")")
            return categories
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func updateCategory(_ category: CategoryMain, oldName: String, oldIcon: String) throws {
        print("Attempting to update category from \(oldName) to \(category.title)")
        
        // Сначала проверяем, существует ли категория с новым именем для текущего пользователя
        let checkFetchRequest: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
        checkFetchRequest.predicate = NSPredicate(format: "name == %@ AND userID == %@", 
            category.title,
            Auth.auth().currentUser?.uid ?? ""
        )
        
        do {
            let existingWithNewName = try context.fetch(checkFetchRequest)
            print("Found \(existingWithNewName.count) categories with new name: \(category.title)")
            
            if !existingWithNewName.isEmpty && existingWithNewName.first?.name != oldName {
                print("Category with new name already exists")
                throw NSError(domain: "CategoryError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Категория с таким названием уже существует"])
            }
            
            // Ищем категорию для обновления
            let fetchRequest: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND userID == %@", 
                oldName,
                Auth.auth().currentUser?.uid ?? ""
            )
            
            let existingCategories = try context.fetch(fetchRequest)
            print("Found \(existingCategories.count) categories with old name: \(oldName)")
            
            guard let existingCategory = existingCategories.first else {
                print("Category to update not found")
                throw NSError(domain: "CategoryError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Категория не найдена"])
            }
            
            print("Updating category")
            // Обновляем существующую категорию
            existingCategory.name = category.title
            existingCategory.icon = category.icon.rawValue
            
            // Сохраняем изменения
            try context.save()
            
            // Обновляем все связанные расходы
            let expenseFetchRequest: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
            expenseFetchRequest.predicate = NSPredicate(format: "category == %@", existingCategory)
            
            let expenses = try context.fetch(expenseFetchRequest)
            print("Updating \(expenses.count) related expenses")
            
            for expense in expenses {
                expense.category = existingCategory
            }
            
            try context.save()
            print("Category updated successfully")
            
            // Отправляем уведомление об изменении категорий
            NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
        } catch {
            print("Error updating category: \(error)")
            throw error
        }
    }
    
    func deleteCategory(_ category: CategoryMain) throws -> Bool {
        let fetchRequest: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND icon == %@ AND userID == %@", 
            category.title, 
            category.icon.rawValue,
            Auth.auth().currentUser?.uid ?? ""
        )
        
        do {
            let existingCategories = try context.fetch(fetchRequest)
            if let existingCategory = existingCategories.first {
                // Проверяем, есть ли связанные расходы
                let expenseFetchRequest: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
                expenseFetchRequest.predicate = NSPredicate(format: "category == %@", existingCategory)
                let relatedExpenses = try context.fetch(expenseFetchRequest)
                
                // Удаляем все связанные расходы
                for expense in relatedExpenses {
                    context.delete(expense)
                }
                
                // Удаляем саму категорию
                context.delete(existingCategory)
                try context.save()
                
                // Отправляем уведомление об изменении категорий
                NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
                
                return true
            }
            return false
        } catch {
            print("Error deleting category: \(error)")
            throw error
        }
    }
    
    func hasRelatedExpenses(_ category: CategoryMain) -> Bool {
        let fetchRequest: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND icon == %@ AND userID == %@", 
            category.title, 
            category.icon.rawValue,
            Auth.auth().currentUser?.uid ?? ""
        )
        
        do {
            let existingCategories = try context.fetch(fetchRequest)
            if let existingCategory = existingCategories.first {
                let expenseFetchRequest: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
                expenseFetchRequest.predicate = NSPredicate(format: "category == %@", existingCategory)
                let relatedExpenses = try context.fetch(expenseFetchRequest)
                return !relatedExpenses.isEmpty
            }
            return false
        } catch {
            print("Error checking related expenses: \(error)")
            return false
        }
    }
} 