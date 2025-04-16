import Foundation
import FirebaseAuth

final class RegistrationViewModel {
    
    var isLoading: Observable<Bool> = Observable(false)
    var isLoggedIn: Observable<Bool> = Observable(false)
    var errorMessage: Observable<String?> = Observable(nil)
    
    func register(email: String, password: String) {
        isLoading.value = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            self.isLoading.value = false
            
            if let error = error {
                self.errorMessage.value = error.localizedDescription
            } else {
                self.isLoggedIn.value = true
            }
        }
    }
}
