import UIKit

final class AuthCoordinator: Coordinator, AuthCoordinatorProtocol {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: AuthCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let authViewModel = AuthViewModel()
        let authViewController = AuthViewController(viewModel: authViewModel)
        authViewController.coordinator = self
        navigationController.setViewControllers([authViewController], animated: true)
    }
    
    func showRegistration() {
       //
    }
    
    func completeAuth() {
        print("kjhgf")
        delegate?.didFinishAuth()
    }
}
