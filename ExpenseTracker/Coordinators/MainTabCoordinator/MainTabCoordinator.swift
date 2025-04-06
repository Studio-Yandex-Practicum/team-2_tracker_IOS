import UIKit

final class MainTabCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let tabBarController: UITabBarController
    
    init(tabBarController: UITabBarController) {
        self.navigationController = UINavigationController()
        self.tabBarController = tabBarController
    }
    
    func start() {
        
    }
}
