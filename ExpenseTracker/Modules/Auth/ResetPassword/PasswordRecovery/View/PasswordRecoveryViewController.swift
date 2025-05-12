import UIKit

final class PasswordRecoveryViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: AuthCoordinator?
    private var customNavigationBar: CustomBackBarItem?
    private let viewModel: PasswordRecoveryViewModel
    
    // MARK: - UI Components
    
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
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .etButtonLabel
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(viewModel: PasswordRecoveryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Methods
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        
        bindViewModel()
        setupNavBar()
        setupViews()
        setupEmailTextField()
        setupSendButton()
        setupTapGesture()
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        viewModel.letterWasSent.bind { [weak self] letterWasSent in
            guard let self else { return }
            if letterWasSent {
                self.coordinator?.dismissAllFlows()
            }
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            guard let self else { return }
            self.sendButton.isEnabled = !isLoading
            if isLoading {
                self.sendButton.setTitle("", for: .normal)
                self.activityIndicator.startAnimating()
            } else {
                self.sendButton.setTitle(ButtonAction.send.rawValue, for: .normal)
                self.activityIndicator.stopAnimating()
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
        customNavigationBar = setupCustomNavBar(title: AuthAction.passwordRecovery.rawValue, backAction: #selector(showAuthFlow))
    }
    
    private func setupViews() {
        [emailTextField, sendButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        sendButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
        ])
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
    
    // MARK: - Actions
    
    @objc
    private func showAuthFlow() {
        if hasUnsavedChanges() {
            let alert = UIAlertController(
                title: AlertLabels.Title.passwordRecovery,
                message: AlertLabels.Message.interruptPasswordRecovery,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: AlertLabels.Button.cancel, style: .cancel))
            alert.addAction(UIAlertAction(title: AlertLabels.Button.interrupt, style: .destructive) { [weak self] _ in
                self?.coordinator?.dismissCurrentFlow()
            })
            
            present(alert, animated: true)
        } else {
            coordinator?.dismissCurrentFlow()
        }
    }
    
    private func hasUnsavedChanges() -> Bool {
        return !(emailTextField.textField.text?.isEmpty ?? true)
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
