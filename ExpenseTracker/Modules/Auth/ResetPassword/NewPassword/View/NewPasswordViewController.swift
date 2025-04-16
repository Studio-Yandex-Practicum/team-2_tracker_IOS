import UIKit

final class PasswordResetViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?
    
    private let newPasswordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private let newPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = AuthAction.auth.rawValue
        label.applyTextStyle(AppTextStyle.largeTitle, textStyle: .largeTitle)
        label.textColor = .etPrimaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let passwordTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.mail.rawValue)
        return textField
    }()
    
    private let confirmPasswordTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.password.rawValue, isEyeIconHidden: false)
        return textField
    }()
    
    private let confirmButton: MainButton = {
        let button = MainButton(title: ButtonAction.login.rawValue, backgroundColor: .etInactive)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        setupViews()
        setupNewPasswordStackView()
    }
    
    private func setupViews() {
        [newPasswordStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupNewPasswordStackView() {
        [newPasswordLabel, passwordTextField, confirmPasswordTextField, confirmButton].forEach {
            newPasswordStackView.addArrangedSubview($0)
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }
        setupNewPasswordStackViewConstraints()
    }
    
    private func setupNewPasswordStackViewConstraints() {
        NSLayoutConstraint.activate([
            newPasswordStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            newPasswordStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newPasswordStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
