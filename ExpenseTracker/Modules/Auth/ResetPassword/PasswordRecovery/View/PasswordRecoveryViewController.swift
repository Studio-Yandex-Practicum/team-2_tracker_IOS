import UIKit

final class PasswordRecoveryViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?
    private var customNavigationBar: CustomBackBarItem?
    private let viewModel: PasswordRecoveryViewModel
    
    private let emailTextField: AuthTextFieldWithHint = {
        let textField = AuthTextField(placeholder: AuthAction.mail.rawValue)
        let hintLabel = TextFieldHint(hintText: AuthValidator.ValidationError.emailAlreadyExists.rawValue)
        let textFieldWithHint = AuthTextFieldWithHint(textField: textField, hintLabel: hintLabel)
        return textFieldWithHint
    }()
    
    private let sendButton: MainButton = {
        let button = MainButton(title: ButtonAction.send.rawValue, backgroundColor: .etInactive)
        return button
    }()
    
    init(viewModel: PasswordRecoveryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        
        bindViewModel()
        setupNavBar()
        setupViews()
        setupEmailTextField()
        setupSendButton()
        setupTapGesture()
    }
    
    private func bindViewModel() {
        viewModel.letterWasSent.bind { [weak self] letterWasSent in
            guard let self else { return }
            if letterWasSent {
                self.coordinator?.dismissAllFlows()
            }
        }
        
        viewModel.isLoginButtonEnabled.bind { [weak self] isButtonEnabled in
            guard let self else { return }
            sendButton.isEnabled = isButtonEnabled
            sendButton.backgroundColor = isButtonEnabled ? .etAccent : .etInactive
        }
        
        viewModel.emailError.bind { [weak self] emailError in
            guard let self else { return }
            if let emailError {
                emailTextField.setErrorHint(with: emailError.rawValue)
            } else {
                emailTextField.setupHint(with: AuthValidator.ValidationError.emailAlreadyExists.rawValue)
            }
        }
    }
    
    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        customNavigationBar = setupCustomNavBar(title: .passwordRecovery, backAction: #selector(showAuthFlow))
    }
    
    private func setupViews() {
        [emailTextField, sendButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupEmailTextField() {
        guard let customNavigationBar else { return }
        emailTextField.textField.addTarget(self, action: #selector(emailTextFieldIsEditing), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSendButton() {
        sendButton.addTarget(self, action: #selector(sendEmailButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -31),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func showAuthFlow() {
        coordinator?.dismissCurrentFlow()
    }
    
    @objc
    private func emailTextFieldIsEditing() {
        guard let email = emailTextField.textField.text else { return }
        viewModel.updateEmail(email)
    }
    
    @objc
    private func sendEmailButtonTapped() {
        guard let email = emailTextField.textField.text, !email.isEmpty else { return }
        viewModel.sendEmailRecoveryLink(email: email)
    }
}
