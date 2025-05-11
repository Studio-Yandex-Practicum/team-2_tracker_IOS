import UIKit

protocol MainTabBarCoordinatorDelegate: AnyObject {
    func didRequestRestart()
}

// Главный координатор для управления таб-баром приложения
final class MainTabBarCoordinator: Coordinator {
    
    // MARK: - Coordinator Properties
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: MainTabBarCoordinatorDelegate?
    
    // MARK: - Private Properties

    private let tabBarController: MainTabBarController
    
    // MARK: - Initialization

    init(tabBarController: MainTabBarController) {
        self.navigationController = UINavigationController()
        self.tabBarController = tabBarController
    }
    
    // MARK: - Coordinator Lifecycle
    
    /// Основной метод запуска координатора
    func start() {
        let coordinators: [TabCoordinator] = [
            ExpensesCoordinator(),     // Координатор для расходов
            AnalyticsCoordinator(),    // Координатор для аналитики
            SettingsCoordinator(delegate: self)      // Координатор для настроек
        ]
        
        coordinators.forEach { coordinator in
            coordinator.start()       // Запускаем логику координатора
            addChild(coordinator)     // Добавляем в иерархию
        }
        
        // Настраиваем таб-бар с созданными координаторами
        tabBarController.setupTabs(with: coordinators)
    }
}

// Реализация протокола SettingsCoordinatorDelegate
extension MainTabBarCoordinator: SettingsCoordinatorDelegate {
    func didRequestLogout() {
        delegate?.didRequestRestart()
    }
}
