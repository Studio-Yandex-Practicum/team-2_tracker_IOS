import Foundation
import FirebaseAuth

final class AuthViewModel {
    
    // MARK: - Properties
    
    private(set) var email: String = ""
    
    var isLoading: Observable<Bool> = Observable(false)
    var isLoggedIn: Observable<Bool> = Observable(false)
    var isLoginButtonEnabled: Observable<Bool> = Observable(false)
    var errorMessage: Observable<String?> = Observable(nil)
    var emailError: Observable<AuthValidator.ValidationError?> = Observable(nil)
    
    // MARK: - Public Methods
    
    func login(email: String, password: String) {
        isLoading.value = true
        
        // Метод входа в систему с email и паролем.
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self else { return }
            isLoading.value = false
            if let error = error {
                errorMessage.value = error.localizedDescription
            } else {
                isLoggedIn.value = true
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
