import UIKit

extension UIViewController {
    
    // Возможность скрывать клавиатуру по тапу в область не предназначенную для ввода
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Позволяет касаниям проходить дальше
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}
