import UIKit

final class RegistrationViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?
    private var customNavigationBar: CustomBackBarItem?
    private let registrationViewModel: RegistrationViewModel
    
    private let registrationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private let loginTextField: AuthTextFieldWithHint = {
        let textField = AuthTextField(placeholder: AuthAction.mail.rawValue)
        let textFieldHint = AuthTextFieldWithHint(textField: textField)
        return textFieldHint
    }()
    
    private let passwordTextField: AuthTextFieldWithHint = {
        let textField = AuthTextField(placeholder: AuthAction.password.rawValue, isEyeIconHidden: false)
        let textFieldHint = AuthTextFieldWithHint(textField: textField)
        return textFieldHint
    }()
    
    private let repeatPasswordTextField: AuthTextFieldWithHint = {
        let textField = AuthTextField(placeholder: AuthAction.repeatPassword.rawValue, isEyeIconHidden: false)
        let hintLabel = TextFieldHint(hintText: AuthValidator.ValidationError.invalidPassword.rawValue)
        let textFieldHint = AuthTextFieldWithHint(textField: textField, hintLabel: hintLabel, isHintHidden: false)
        return textFieldHint
    }()
    
    private let footerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        return stackView
    }()
    
    private let checkBoxButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Asset.Icon.checkboxDefault.rawValue)?.withTintColor(.etAccent), for: .normal)
        button.isSelected = false
        return button
    }()
    
    private let privacyPolicyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private let privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .etPrimaryLabel
        label.text = AuthAction.registrationPrivacyPolicy.rawValue
        label.numberOfLines = 2
        label.applyTextStyle(.caption, textStyle: .caption1)
        return label
    }()
    
    private let privacyPolicyButton: LinkedButton = {
        let button = LinkedButton(title: ButtonAction.privacyPolicy.rawValue)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.applyTextStyle(.caption, textStyle: .caption1)
        return button
    }()
    
    private let registrationButton: MainButton = {
        let button = MainButton(title: ButtonAction.register.rawValue)
        return button
    }()
    
    init(viewModel: RegistrationViewModel) {
        self.registrationViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
    }
    
    private func bindViewModel() {
        registrationViewModel.isLoading.bind { [weak self] isLoading in
            guard let self else { return }
            self.registrationButton.isEnabled = !isLoading
        }
        
        registrationViewModel.isLoggedIn.bind { [weak self] isLoggedIn in
            guard let self else { return }
            if isLoggedIn {
                coordinator?.completeAuth()
            }
        }
        
        registrationViewModel.emailError.bind { [weak self] emailError in
            guard let self else { return }
            if let emailError {
                loginTextField.setErrorHint(with: emailError.rawValue)
            } else {
                loginTextField.removeHint()
            }
        }
        
        registrationViewModel.passwordError.bind { [weak self] passwordError in
            guard let self else { return }
            if let passwordError {
                passwordTextField.setErrorHint(with: passwordError.rawValue)
            } else {
                passwordTextField.removeHint()
            }
        }
        
        registrationViewModel.confirmPasswordError.bind { [weak self] confirmPasswordError in
            guard let self else { return }
            if let confirmPasswordError {
                repeatPasswordTextField.setErrorHint(with: confirmPasswordError.rawValue)
            } else {
                repeatPasswordTextField.setupHint(with: AuthValidator.ValidationError.invalidPassword.rawValue)
            }
        }
        
        registrationViewModel.isButtonEnabled.bind { [weak self] isButtonEnabled in
            guard let self else { return }
            registrationButton.isEnabled = isButtonEnabled
            registrationButton.backgroundColor = isButtonEnabled ? .etAccent : .etInactive
        }
        
        registrationViewModel.errorMessage.bind { [weak self] error in
            guard let self else { return }
            
            if error != nil {
                loginTextField.setErrorHint(with: AuthValidator.ValidationError.alreadyRegistered.rawValue)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        
        setupNavBar()
        setupViews()
        setupRegistrationStackView()
        setupPrivacyPolicyStackView()
        setupFooterStackView()
        setupCheckBoxButton()
        setupPrivacyPolicyButton()
        setupRegistrationButton()
        setupTapGesture()
        setupTextFieldTargets()
    }
    
    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Расширение UIViewController+setupCustomNavBar для кастомной навигации
        customNavigationBar = setupCustomNavBar(title: AuthAction.registration.rawValue, backAction: #selector(showAuthFlow))
    }
    
    private func setupViews() {
        [registrationStackView, footerStackView, privacyPolicyStackView, registrationButton]
        .forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupRegistrationStackView() {
        [loginTextField, passwordTextField, repeatPasswordTextField]
        .forEach {
            registrationStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        setupRegistrationStackViewConstraints()
    }
    
    private func setupRegistrationStackViewConstraints() {
        guard let customNavigationBar else { return }
        
        NSLayoutConstraint.activate([
            registrationStackView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: 20),
            registrationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            registrationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupFooterStackView() {
        [checkBoxButton, privacyPolicyStackView].forEach {
            footerStackView.addArrangedSubview($0)
        }
        setupFooterStackViewConstraints()
    }
    
    private func setupFooterStackViewConstraints() {
        NSLayoutConstraint.activate([
            footerStackView.bottomAnchor.constraint(equalTo: registrationButton.topAnchor, constant: -28),
            footerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            footerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCheckBoxButton() {
        checkBoxButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        checkBoxButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        checkBoxButton.addTarget(self, action: #selector(checkBoxButtonTapped), for: .touchUpInside)
    }
    
    private func setupPrivacyPolicyStackView() {
        [privacyPolicyLabel, privacyPolicyButton].forEach {
            privacyPolicyStackView.addArrangedSubview($0)
        }
    }
    
    private func setupPrivacyPolicyButton() {
        privacyPolicyButton.addTarget(self, action: #selector(showPrivacyPolicyFlow), for: .touchUpInside)
    }
    
    private func setupRegistrationButton() {
        registrationButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        setupRegistrationButtonConstraints()
    }
    
    private func setupRegistrationButtonConstraints() {
        NSLayoutConstraint.activate([
            registrationButton.heightAnchor.constraint(equalToConstant: 48),
            registrationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -31),
            registrationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            registrationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupTextFieldTargets() {
        loginTextField.textField.addTarget(self, action: #selector(loginTextFieldEditing), for: .editingChanged)
        loginTextField.textField.addTarget(self, action: #selector(loginTextFieldDidEndEditing), for: .editingDidEnd)
        
        passwordTextField.textField.addTarget(self, action: #selector(passwordTextFieldEditing), for: .editingChanged)
        passwordTextField.textField.addTarget(self, action: #selector(passwordTextFieldDidEndEditing), for: .editingDidEnd)
        
        repeatPasswordTextField.textField.addTarget(self, action: #selector(repeatPasswordTextEditing), for: .editingChanged)
        repeatPasswordTextField.textField.addTarget(self, action: #selector(repeatPasswordTextDidEndEditing), for: .editingDidEnd)
    }
    
    @objc
    private func loginTextFieldEditing() {
        guard let email = loginTextField.textField.text else { return }
        registrationViewModel.updateEmail(email)
    }
    
    @objc
    private func loginTextFieldDidEndEditing() {
        registrationViewModel.validateEmail()
    }
    
    @objc
    private func passwordTextFieldEditing() {
        guard let password = passwordTextField.textField.text else { return }
        registrationViewModel.updatePassword(password)
    }
    
    @objc
    private func passwordTextFieldDidEndEditing() {
        registrationViewModel.validatePassword()
    }
    
    @objc
    private func repeatPasswordTextEditing() {
        guard let confirmPassword = repeatPasswordTextField.textField.text else { return }
        registrationViewModel.updateConfirmPassword(confirmPassword)
    }
    
    @objc
    private func repeatPasswordTextDidEndEditing() {
        registrationViewModel.doPasswordsMatch()
    }
    
    @objc
    private func showAuthFlow() {
        coordinator?.dismissCurrentFlow()
    }
    
    @objc
    private func signIn() {
        registrationViewModel.register()
    }
    
    @objc
    private func checkBoxButtonTapped() {
        checkBoxButton.isSelected.toggle()
        registrationViewModel.updateSelectedPolicyPrivacy(checkBoxButton.isSelected)
        
        if checkBoxButton.isSelected {
            checkBoxButton.setImage(UIImage(named: Asset.Icon.checkboxPressed.rawValue), for: .normal)
        } else {
            checkBoxButton.setImage(UIImage(named: Asset.Icon.checkboxDefault.rawValue), for: .normal)
        }
    }
    
    @objc
    private func showPrivacyPolicyFlow() {
        coordinator?.showPrivacyPolicy()
    }
}
