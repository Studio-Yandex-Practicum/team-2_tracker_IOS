import Foundation
import FirebaseAuth

final class PasswordRecoveryViewModel {
    
    // MARK: - Properties
    
    private(set) var email: String = ""
    
    var letterWasSent: Observable<Bool> = Observable(false)
    var isLoginButtonEnabled: Observable<Bool> = Observable(false)
    var emailError: Observable<AuthValidator.ValidationError?> = Observable(nil)
    
    // MARK: - Public Methods
    
    func sendEmailRecoveryLink(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self else { return }
            if error != nil {
            } else {
                letterWasSent.value = true
            }
        }
    }
    
    func updateEmail(_ email: String) {
        self.email = email
        validateEmail()
    }
    
    func validateEmail() {
        let isEmailValid = AuthValidator.isValidEmail(email)
        emailError.value = isEmailValid ? nil : .invalidEmail
        isLoginButtonEnabled.value = isEmailValid
    }
}
