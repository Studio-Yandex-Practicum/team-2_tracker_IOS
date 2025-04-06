import UIKit

final class AuthViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?
    
    init(viewModel: AuthViewModel) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
