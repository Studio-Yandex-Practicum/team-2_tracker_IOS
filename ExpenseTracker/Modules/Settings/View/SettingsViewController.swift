import UIKit

final class ExpensesViewController: UIViewController {
    
    weak var coordinator: ExpensesCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
    }
}
