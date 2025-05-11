import UIKit
import FirebaseAuth

protocol SettingsCoordinatorDelegate: AnyObject {
    func didRequestLogout()
}

// Координатор для настроек
final class SettingsCoordinator: Coordinator {

    // MARK: - Coordinator Properties
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: SettingsCoordinatorDelegate?
    
    // MARK: - Initialization
    
    init(delegate: SettingsCoordinatorDelegate) {
        self.navigationController = UINavigationController()
        self.delegate = delegate
        configureTabBarItem()
    }
    
    // MARK: - Coordinator Lifecycle
    
    func start() {
        let settingsViewController = SettingsViewController()
        settingsViewController.coordinator = self
        navigationController.setViewControllers([settingsViewController], animated: true)
    }
    
    func exit() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error)")
        }
        delegate?.didRequestLogout()
    }
}

extension SettingsCoordinator: TabCoordinator {
    var tabItem: TabItem { .settings }
    
    private func configureTabBarItem() {
        navigationController.tabBarItem = UITabBarItem(
            title: tabItem.title,
            image: tabItem.icon,
            tag: 2
        )
    }
}
