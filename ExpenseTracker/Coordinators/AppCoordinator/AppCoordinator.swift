import UIKit

// Основной координатор приложения, управляющий потоками авторизации и основным интерфейсом
final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = [] // Массив дочерних координаторов
    var navigationController: UINavigationController
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.navigationController = UINavigationController()
        self.window = window
    }
    
    // Основной метод запуска координатора
    func start() {
        // Проверяем статус авторизации пользователя
        if UserDefaults.isLoggedIn {
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
        addChild(mainCoordinator)
        mainCoordinator.start()
    }
    
    // Показывает поток авторизации
    private func showAuthFlow() {
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
        UserDefaults.isLoggedIn = true
        showMainFlow()
    }
}
