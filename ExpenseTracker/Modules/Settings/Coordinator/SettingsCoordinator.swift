import UIKit

// Координатор для настроек
final class SettingsCoordinator: Coordinator {

    // MARK: - Coordinator Properties
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Initialization
    
    init() {
        self.navigationController = UINavigationController()
        configureTabBarItem()
    }
    
    // MARK: - Coordinator Lifecycle
    
    func start() {
        let settingsViewController = SettingsViewController()
        settingsViewController.coordinator = self
        navigationController.setViewControllers([settingsViewController], animated: true)
    }
}

extension SettingsCoordinator: TabCoordinator {
    var tabItem: TabItem { .settings }
    
    private func configureTabBarItem() {
        navigationController.tabBarItem = UITabBarItem(
            title: tabItem.title,
            image: tabItem.icon,
            tag: 0
        )
    }
}
