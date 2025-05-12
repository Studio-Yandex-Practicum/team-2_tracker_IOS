import UIKit

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: AuthCoordinator?
    private let authViewModel: AuthViewModel

    // MARK: - UI Components
    
    private let authStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private let authLabel: UILabel = {
        let label = UILabel()
        label.text = AuthAction.auth.rawValue
        label.applyTextStyle(AppTextStyle.largeTitle, textStyle: .largeTitle)
        label.textColor = .etPrimaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let loginTextField: AuthTextFieldWithHint = {
        let textField = AuthTextField(placeholder: AuthAction.mail.rawValue)
        let textFieldWithHint = AuthTextFieldWithHint(textField: textField, hintLabel: TextFieldHint(hintText: ""))
        return textFieldWithHint
    }()
    
    private let passwordTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.password.rawValue, isEyeIconHidden: false)
        return textField
    }()
    
    private let forgotPasswordButton: LinkedButton = {
        let button = LinkedButton(title: ButtonAction.forgotPassword.rawValue)
        button.contentVerticalAlignment = .bottom
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    private let loginButton: MainButton = {
        let button = MainButton(title: ButtonAction.login.rawValue, backgroundColor: .etInactive)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .etButtonLabel
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let footerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .etPrimaryLabel
        label.text = AuthAction.areFirstInApp.rawValue
        label.applyTextStyle(.caption, textStyle: .caption1)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.textAlignment = .right
        return label
    }()
    
    private let footerButton: LinkedButton = {
        let button = LinkedButton(title: ButtonAction.createAccount.rawValue)
        button.contentHorizontalAlignment = .leading
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    // MARK: - Initialization
            
    init(viewModel: AuthViewModel) {
        self.authViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
    }
    
    // MARK: - Private Methods
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        authViewModel.isLoading.bind { [weak self] isLoading in
            guard let self else { return }
            self.loginButton.isEnabled = !isLoading
            if isLoading {
                self.loginButton.setTitle("", for: .normal)
                self.activityIndicator.startAnimating()
            } else {
                self.loginButton.setTitle(ButtonAction.login.rawValue, for: .normal)
                self.activityIndicator.stopAnimating()
            }
        }
        
        authViewModel.isLoginButtonEnabled.bind { [weak self] isButtonEnabled in
            guard let self else { return }
            loginButton.isEnabled = isButtonEnabled
            loginButton.backgroundColor = isButtonEnabled ? .etAccent : .etInactive
        }
        
        authViewModel.emailError.bind { [weak self] emailError in
            guard let self else { return }
            if let emailError {
                loginTextField.setErrorHint(with: emailError.rawValue)
            } else {
                loginTextField.removeHint()
            }
        }
        
        authViewModel.isLoggedIn.bind { [weak self] isLoggedIn in
            guard let self else { return }
            if isLoggedIn {
                coordinator?.completeAuth()
            }
        }
        
        authViewModel.errorMessage.bind { [weak self] error in
            guard let self else { return }
            if error != nil {
                self.loginTextField.setErrorHint(with: AuthValidator.ValidationError.authFailed.rawValue)
            }
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        setupViews()
        setupAuthStackView()
        setupFooterStackView()
        setupButtonTargets()
        setupTapGesture()
    }
    
    private func setupViews() {
        [authStackView, footerStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        loginButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor)
        ])
    }
    
    private func setupAuthStackView() {
        [authLabel, loginTextField, passwordTextField, forgotPasswordButton, loginButton].forEach {
            authStackView.addArrangedSubview($0)
            if $0 == forgotPasswordButton {
                $0.heightAnchor.constraint(equalToConstant: 28).isActive = true
            }
        }
        setupAuthStackViewConstraints()
    }
    
    private func setupAuthStackViewConstraints() {
        NSLayoutConstraint.activate([
            authStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            authStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupFooterStackView() {
        footerStackView.addArrangedSubview(footerLabel)
        footerStackView.addArrangedSubview(footerButton)
        
        setupFooterStackViewConstraints()
    }
    
    private func setupFooterStackViewConstraints() {
        NSLayoutConstraint.activate([
            footerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -31),
            footerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            footerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupButtonTargets() {
        loginTextField.textField.addTarget(self, action: #selector(loginTextFieldIsEditing), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        passwordTextField.addTarget(self, action: #selector(passwordFieldIsEditing), for: .editingChanged)
        
        forgotPasswordButton.addTarget(self, action: #selector(showPasswordRecover), for: .touchUpInside)
        footerButton.addTarget(self, action: #selector(showRegistrationView), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    private func showPasswordRecover() {
        coordinator?.showPasswordRecovery()
    }
    
    @objc
    private func loginTextFieldIsEditing() {
        guard let email = loginTextField.textField.text else { return }
        authViewModel.updateEmail(email)
    }
    
    @objc
    private func passwordFieldIsEditing() {
        guard let password = passwordTextField.text else { return }
        authViewModel.updatePassword(password.isEmpty)
    }
    
    @objc
    private func signIn() {
        guard
            let email = loginTextField.textField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else { return }
        authViewModel.login(email: email, password: password)
    }

    @objc
    private func showRegistrationView() {
        coordinator?.showRegistration()
    }
}
