import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let isLoggedIn = Auth.auth().currentUser != nil // Проверка текущей сессии пользователя
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Применяем сохраненную тему
        let isDarkTheme = UserDefaults.standard.bool(forKey: "isDarkTheme")
        window.overrideUserInterfaceStyle = isDarkTheme ? .dark : .light
        
        appCoordinator = AppCoordinator(window: window, isLoggedIn: isLoggedIn)
        appCoordinator?.start()
    }
}
