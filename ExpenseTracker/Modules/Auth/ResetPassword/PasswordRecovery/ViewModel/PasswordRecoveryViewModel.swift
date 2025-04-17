import Foundation
import FirebaseAuth

final class PasswordRecoveryViewModel {
    
    var letterWasSent: Observable<Bool> = Observable(false)
    var errorMessage: Observable<String?> = Observable(nil)
    
    func sendEmailRecoveryLink(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self else { return }
            
            if let error = error {
                self.errorMessage.value = error.localizedDescription
            } else {
                self.letterWasSent.value = true 
            }
        }
    }
}
