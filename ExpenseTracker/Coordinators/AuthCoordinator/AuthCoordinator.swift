import UIKit

final class AuthCoordinator: Coordinator, AuthCoordinatorProtocol {
    
    // MARK: - Properties

    var childCoordinators: [Coordinator] = [] // Массив для хранения дочерних координаторов
    var navigationController: UINavigationController
    weak var delegate: AuthCoordinatorDelegate?
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Coordinator Methods
    
    /// Основной метод запуска координатора
    func start() {
        let authViewModel = AuthViewModel()
        let authViewController = AuthViewController(viewModel: authViewModel)
        authViewController.coordinator = self
        
        // Устанавливаем ViewController как корневой в навигационном контроллере
        navigationController.setViewControllers([authViewController], animated: true)
    }
    
    func showRegistration() {
        let registrationViewController = RegistrationViewController()
        registrationViewController.coordinator = self
        navigationController.pushViewController(registrationViewController, animated: true)
    }
    
    func showPrivacyPolicy() {
        let privacyPolicyViewController = PrivacyPolicyViewController()
        privacyPolicyViewController.coordinator = self
        navigationController.pushViewController(privacyPolicyViewController, animated: true)
    }
    
    func showPasswordRecovery() {
        let passwordRecoveryViewController = PasswordRecoveryViewController()
        passwordRecoveryViewController.coordinator = self
        navigationController.pushViewController(passwordRecoveryViewController, animated: true)
    }
    
    func dismissCurrentFlow() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - Auth Flow Methods
    
    func completeAuth() {
        delegate?.didFinishAuth()
    }
}
