import UIKit

protocol AppCoordinatorDelegate: AnyObject {
    func didRequestRestart()
}

// Основной координатор приложения, управляющий потоками авторизации и основным интерфейсом
final class AppCoordinator: Coordinator, MainTabBarCoordinatorDelegate {
    
    var childCoordinators: [Coordinator] = [] // Массив дочерних координаторов
    var navigationController: UINavigationController
    
    private let window: UIWindow
    private let isLoggedIn: Bool
    weak var delegate: AppCoordinatorDelegate?
    
    init(window: UIWindow, isLoggedIn: Bool = false) {
        self.navigationController = UINavigationController()
        self.window = window
        self.isLoggedIn = isLoggedIn
    }
    
    // Основной метод запуска координатора
    func start() {
        // Проверяем статус авторизации пользователя
        if isLoggedIn {
            showMainFlow() // Если пользователь авторизован, показываем основной поток
        } else {
            showAuthFlow() // Если нет, показываем поток авторизации
        }
    }
    
    // Показывает основной поток приложения (после успешной авторизации)
    private func showMainFlow() {
        let tabBarController = MainTabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        // Создаем и запускаем координатор для основного потока
        let mainCoordinator = MainTabBarCoordinator(tabBarController: tabBarController)
        mainCoordinator.delegate = self
        addChild(mainCoordinator)
        mainCoordinator.start()
    }
    
    // Показывает поток авторизации
    private func showAuthFlow() {
        // Очищаем все дочерние координаторы
        childCoordinators.removeAll()
        
        // Создаем новый навигационный контроллер
        let newNavigationController = UINavigationController()
        self.navigationController = newNavigationController
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        addChild(authCoordinator)
        authCoordinator.start()
    }
}

// Реализация протокола AuthCoordinatorDelegate для обработки завершения авторизации
extension AppCoordinator: AuthCoordinatorDelegate {
    
    // Метод вызывается при успешной авторизации
    func didFinishAuth() {
        showMainFlow()
    }
}

// Реализация протокола AppCoordinatorDelegate
extension AppCoordinator: AppCoordinatorDelegate {
    func didRequestRestart() {
        // Очищаем все дочерние координаторы
        childCoordinators.removeAll()
        
        // Очищаем текущий rootViewController
        window.rootViewController = nil
        
        // Показываем поток авторизации
        showAuthFlow()
    }
}
