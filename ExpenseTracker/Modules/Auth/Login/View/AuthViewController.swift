import UIKit

final class AuthViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?

    private let authStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private let authLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AuthAction.auth.rawValue
        label.applyTextStyle(AppTextStyle.h1, textStyle: .title1)
        label.textColor = .etPrimaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let loginTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.login.rawValue)
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
        setupAuthStackViewConstraints()
        setupFooterStackViewConstraints()
    }
    
    private func setupAuthStackViewConstraints() {
        view.addSubview(authStackView)
        
        [authLabel, loginTextField, passwordTextField, forgotPasswordButton, loginButton].forEach {
            authStackView.addArrangedSubview($0)
            if $0 == forgotPasswordButton {
                $0.heightAnchor.constraint(equalToConstant: 28).isActive = true
            } else {
                $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
            }
        }
        
        NSLayoutConstraint.activate([
            authStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            authStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupFooterStackViewConstraints() {
        view.addSubview(footerStackView)
        footerStackView.addArrangedSubview(footerLabel)
        footerStackView.addArrangedSubview(footerButton)
        
        NSLayoutConstraint.activate([
            footerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -31),
            footerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            footerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
