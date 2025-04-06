import UIKit

// Координатор для аналитики расходов
final class AnalyticsCoordinator: Coordinator {
    
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
        let analyticsViewController = AnalyticsViewController()
        analyticsViewController.coordinator = self
        navigationController.setViewControllers([analyticsViewController], animated: true)
    }
}

extension AnalyticsCoordinator: TabCoordinator {
    var tabItem: TabItem { .analytics }
    
    private func configureTabBarItem() {
        navigationController.tabBarItem = UITabBarItem(
            title: tabItem.title,
            image: tabItem.icon,
            tag: 0
        )
    }
}
