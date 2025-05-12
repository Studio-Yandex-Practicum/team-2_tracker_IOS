import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Применяем сохраненную тему
        let isDarkTheme = UserDefaults.standard.bool(forKey: "isDarkTheme")
        window.overrideUserInterfaceStyle = isDarkTheme ? .dark : .light
        
        // Показываем экран загрузки или сплеш-скрин
        let loadingViewController = UIViewController()
        loadingViewController.view.backgroundColor = .etBackground
        window.rootViewController = loadingViewController
        window.makeKeyAndVisible()
        
        // Проверяем авторизацию асинхронно
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let isLoggedIn = Auth.auth().currentUser != nil
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.appCoordinator = AppCoordinator(window: window, isLoggedIn: isLoggedIn)
                self.appCoordinator?.start()
            }
        }
    }
}
