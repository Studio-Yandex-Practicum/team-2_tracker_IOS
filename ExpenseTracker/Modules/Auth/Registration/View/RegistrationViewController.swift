import UIKit

final class RegistrationViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?
    private var customNavigationBar: CustomBackBarItem?
    
    private let registrationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private let loginTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.mail.rawValue)
        return textField
    }()
    
    private let passwordTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.password.rawValue, isEyeIconHidden: false)
        return textField
    }()
    
    private let repeatPasswordTextField: AuthTextField = {
        let textField = AuthTextField(placeholder: AuthAction.repeatPassword.rawValue, isEyeIconHidden: false)
        return textField
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
        let button = MainButton(title: ButtonAction.register.rawValue, backgroundColor: .etInactive)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        setupRegistrationButtonConstraints()
        setupTapGesture()
    }
    
    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Расширение UIViewController+setupCustomNavBar для кастомной навигации
        customNavigationBar = setupCustomNavBar(title: .registration, backAction: #selector(showAuthFlow))
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
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
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
    
    private func setupRegistrationButtonConstraints() {
        NSLayoutConstraint.activate([
            registrationButton.heightAnchor.constraint(equalToConstant: 48),
            registrationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -31),
            registrationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            registrationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func showAuthFlow() {
        coordinator?.dismissCurrentFlow()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func checkBoxButtonTapped() {
        checkBoxButton.isSelected.toggle()
        
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
