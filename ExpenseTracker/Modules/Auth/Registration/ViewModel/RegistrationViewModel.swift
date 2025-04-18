import Foundation
import FirebaseAuth

final class RegistrationViewModel {
    
    // MARK: - Properties
    
    private(set) var email: String = ""
    private(set) var password: String = ""
    private(set) var confirmPassword: String = ""
    private(set) var isSelectedPolicyPrivacy: Bool = false
    
    // States
    var isLoading: Observable<Bool> = Observable(false)
    var isLoggedIn: Observable<Bool> = Observable(false)
    var isButtonEnabled: Observable<Bool> = Observable(false)
    
    // Validation and errors
    var errorMessage: Observable<String?> = Observable(nil)
    var validationError: Observable<[AuthValidator.ValidationError]?> = Observable(nil)
    var emailError: Observable<AuthValidator.ValidationError?> = Observable(nil)
    var passwordError: Observable<AuthValidator.ValidationError?> = Observable(nil)
    var confirmPasswordError: Observable<AuthValidator.ValidationError?> = Observable(nil)
    
    // MARK: - Public Methods
    
    func updateEmail(_ email: String) {
        self.email = email
        validateEmail()
    }
    
    func updatePassword(_ password: String) {
        self.password = password
        validatePassword()
    }
    
    func updateConfirmPassword(_ confirmPassword: String) {
        self.confirmPassword = confirmPassword
        doPasswordsMatch()
    }
    
    func updateSelectedPolicyPrivacy(_ isSelectedPolicyPrivacy: Bool) {
        self.isSelectedPolicyPrivacy = isSelectedPolicyPrivacy
        validateFieldsForFilled()
    }
    
    func register() {
        isLoading.value = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            guard let self else { return }
            isLoading.value = false
            
            if let error = error {
                errorMessage.value = error.localizedDescription
            } else {
                isLoggedIn.value = true
            }
        }
    }

    func validateFieldsForFilled() {
        let allFieldsFilled = !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && isSelectedPolicyPrivacy
        let allFieldsValid = emailError.value == nil && passwordError.value == nil && confirmPasswordError.value == nil
        isButtonEnabled.value = allFieldsFilled && allFieldsValid
    }
    
    func validateEmail() {
        emailError.value = AuthValidator.isValidEmail(email) ? nil : .invalidEmail
        validateFieldsForFilled()
    }

    func validatePassword() {
        passwordError.value = AuthValidator.isValidPassword(password) ? nil : .invalidPassword
        validateFieldsForFilled()
    }
    
    func doPasswordsMatch() {
        confirmPasswordError.value = AuthValidator.doPasswordsMatch(password, confirmPassword) ? nil : .passwordsDoNotMatch
        validateFieldsForFilled()
    }
}
