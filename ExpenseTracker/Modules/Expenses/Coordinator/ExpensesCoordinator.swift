import UIKit

// Координатор для расходов
final class ExpensesCoordinator: Coordinator {

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
        let expensesViewController = ExpensesViewController()
        expensesViewController.coordinator = self
        navigationController.setViewControllers([expensesViewController], animated: true)
    }
}

extension ExpensesCoordinator: TabCoordinator {
    var tabItem: TabItem { .expenses }
    
    private func configureTabBarItem() {
        navigationController.tabBarItem = UITabBarItem(
            title: tabItem.title,
            image: tabItem.icon,
            tag: 0
        )
    }
}
