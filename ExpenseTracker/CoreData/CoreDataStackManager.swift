import CoreData

// Менеджер для работы с CoreData stack (синглтон)
final class CoreDataStackManager {
    
    // MARK: - Singleton Instance
    
    static let shared = CoreDataStackManager()
    
    private init() {
        setupPersistentContainer()
    }
    
    private var persistentContainer: NSPersistentContainer!
    
    private func setupPersistentContainer() {
        persistentContainer = NSPersistentContainer(name: "ExpenseTrackerCoreData")
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Convenience Properties
    
    /// Основной контекст для работы с данными
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving Support
    
    /// Сохранение изменений в контексте
    func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
