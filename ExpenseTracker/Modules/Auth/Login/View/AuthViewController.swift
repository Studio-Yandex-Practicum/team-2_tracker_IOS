import UIKit

final class AuthViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?

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
    
    private let loginTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.mail.rawValue)
        return textField
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
            
    init(viewModel: AuthViewModel) {
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
    }
    
    private func setupAuthStackView() {
        [authLabel, loginTextField, passwordTextField, forgotPasswordButton, loginButton].forEach {
            authStackView.addArrangedSubview($0)
            if $0 == forgotPasswordButton {
                $0.heightAnchor.constraint(equalToConstant: 28).isActive = true
            } else {
                $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
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
        forgotPasswordButton.addTarget(self, action: #selector(showPasswordRecover), for: .touchUpInside)
        footerButton.addTarget(self, action: #selector(showRegistrationView), for: .touchUpInside)
    }
    
    // Возможность скрывать клавиатуру по тапу в область не предназначенную для ввода
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func showPasswordRecover() {
        coordinator?.showPasswordRecovery()
    }

    @objc
    private func showRegistrationView() {
        coordinator?.showRegistration()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}
