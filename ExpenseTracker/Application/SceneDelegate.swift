import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
     
        UserDefaults.isLoggedIn = true
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
            
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
    }
}
