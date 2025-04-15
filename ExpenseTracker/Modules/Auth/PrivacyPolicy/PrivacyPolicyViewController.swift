import UIKit

final class PrivacyPolicyViewController: UIViewController {
    
    weak var coordinator: AuthCoordinator?
    private var customNavigationBar: CustomBackBarItem?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let policyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .etPrimaryLabel
        label.numberOfLines = 0
        label.applyTextStyle(.caption, textStyle: .caption1)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        
        setupNavBar()
        setupScrollView()
        setupContentStackView()
        setupPolicyLabel()
    }
    
    private func setupNavBar() {
        navigationItem.hidesBackButton = true
        customNavigationBar = setupCustomNavBar(title: .privacyPolicy, isPolicyPrivacyFlow: true, backAction: #selector(showRegistrationFlow))
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        setupScrollViewConstraints()
    }
    
    private func setupScrollViewConstraints() {
        guard let customNavigationBar else { return }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContentStackView() {
        contentStackView.addArrangedSubview(policyLabel)
        setupContentStackViewConstraints()
    }
    
    private func setupContentStackViewConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupPolicyLabel() {
        policyLabel.text = recievePolicyText()
    }
    
    private func recievePolicyText() -> String {
        guard let fileURL = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "txt"),
              let text = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return "Не удалось загрузить текст политики конфиденциальности."
        }
        return text
    }
    
    @objc
    private func showRegistrationFlow() {
        coordinator?.dismissCurrentFlow()
    }
}
