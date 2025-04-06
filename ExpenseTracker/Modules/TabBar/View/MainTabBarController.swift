import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    
    private let tabItems: [TabItem] = TabItem.allCases
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    // MARK: - Public Interface
    
    func setupTabs(with coordinators: [TabCoordinator]) {
        viewControllers = coordinators.map { $0.navigationController }
    }
    
    // MARK: - Configuration
    
    private func configureTabBar() {
        styleTabBar()
        
        // Настройка делегата для кастомных анимаций (только для iOS 18+)
        // Я задала данную настройку по причине бага при переключении TabBarItems именно на данной версии iOS
        if #available(iOS 18.0, *) {
            delegate = self
        }
    }
    
    private func styleTabBar() {
        tabBar.tintColor = .etCards
        tabBar.unselectedItemTintColor = .etInactive
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .etBackground
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
 
extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self // Возвращаем себя как обработчик анимации
    }
}
 
extension MainTabBarController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return .zero // Мгновенный переход без анимации
    }
 
    /// Выполнение кастомной анимации перехода
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let view = transitionContext.view(forKey: .to) else { return }
    
        let container = transitionContext.containerView
        container.addSubview(view)
        transitionContext.completeTransition(true)
    }
}
