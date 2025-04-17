import UIKit

final class PasswordRecoveryViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?
    private var customNavigationBar: CustomBackBarItem?
    private let viewModel: PasswordRecoveryViewModel
    
    private let emailTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.mail.rawValue)
        return textField
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
    }
    
    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        customNavigationBar = setupCustomNavBar(title: .passwordRecovery, backAction: #selector(showAuthFlow))
    }
    
    private func setupViews() {
        [emailTextField, sendButton].forEach {
            view.addSubview($0)
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }
    }
    
    private func setupEmailTextField() {
        guard let customNavigationBar else { return }
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
    private func sendEmailButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        viewModel.sendEmailRecoveryLink(email: email)
    }
}
