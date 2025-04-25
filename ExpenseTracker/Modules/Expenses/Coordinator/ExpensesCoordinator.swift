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
    
    func showCategorySelectionFlow() {
        let categorySelectionController = CategorySelectionViewController(isSelectionFlow: true)
        categorySelectionController.coordinator = self
        categorySelectionController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(categorySelectionController, animated: true)
    }
    
    func showNewCategoryFlow() {
        let newCategoryController = NewCategoryViewController()
        newCategoryController.coordinator = self
        newCategoryController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(newCategoryController, animated: true)
    }
    
    func dismissCurrentFlow() {
        navigationController.popViewController(animated: true)
    }
    
    func dismissAllFlows() {
        navigationController.popToRootViewController(animated: true)
    }
}

extension ExpensesCoordinator: TabCoordinator {
    var tabItem: TabItem { .expenses }
    
    private func configureTabBarItem() {
        navigationController.tabBarItem = UITabBarItem(
            title: tabItem.title,
            image: tabItem.icon,
            tag: 1
        )
    }
}
