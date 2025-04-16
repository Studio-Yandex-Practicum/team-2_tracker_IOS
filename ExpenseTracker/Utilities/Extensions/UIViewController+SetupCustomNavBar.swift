import UIKit

extension UIViewController {
    
    // Создание кастомного навигационного бара
    func setupCustomNavBar(
        title: AuthAction,
        isPolicyPrivacyFlow: Bool = false,
        backAction: Selector
    ) -> CustomBackBarItem {
        let navBar = CustomBackBarItem(
            title: title.rawValue,
            isPolicyPrivacyFlow: isPolicyPrivacyFlow,
            target: self,
            action: backAction
        )
        view.addSubview(navBar)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        return navBar
    }
}
