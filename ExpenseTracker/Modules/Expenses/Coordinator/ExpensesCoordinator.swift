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
    
    func showAddExpenseFlow(with delegate: ChangeExpensesDelegate) {
        let addExpenseViewController = ChangeExpensesViewController(.add)
        addExpenseViewController.coordinator = self
        addExpenseViewController.delegate = delegate
        addExpenseViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(addExpenseViewController, animated: true)
    }
    
    func showChangeExpenseFlow(with delegate: ChangeExpensesDelegate, expense: Expense) {
        let addExpenseViewController = ChangeExpensesViewController(.change, expense: expense)
        addExpenseViewController.coordinator = self
        addExpenseViewController.delegate = delegate
        addExpenseViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(addExpenseViewController, animated: true)
    }
    
    func showCategorySelectionOneFlow(with delegateExpence: CategoryForExpenseDelegate) {
        let categorySelectionController = CategorySelectionViewController(isSelectionFlow: true)
        categorySelectionController.coordinator = self
        categorySelectionController.delegateExpence = delegateExpence
        categorySelectionController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(categorySelectionController, animated: true)
    }
    
    func showCategorySelectionFlow() {
        let categorySelectionController = CategorySelectionViewController(isSelectionFlow: true)
        categorySelectionController.coordinator = self
        categorySelectionController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(categorySelectionController, animated: true)
    }
        
    func showCategoryFiltersFlow() {
        let categorySelectionController = CategorySelectionViewController(isSelectionFlow: false)
        categorySelectionController.coordinator = self
        categorySelectionController.delegate = navigationController.viewControllers.last as? CategorySelectionDelegate
        categorySelectionController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(categorySelectionController, animated: true)
    }
    
    func showNewCategoryFlow(with delegate: CreateCategoryDelegate) {
        let newCategoryController = NewCategoryViewController()
        newCategoryController.coordinator = self
        newCategoryController.delegate = delegate
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
