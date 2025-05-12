import UIKit

final class SettingsViewController: UIViewController {
    
    weak var coordinator: SettingsCoordinator?
    
    private var customNavigationBar: CustomBackBarItem?
    
    // MARK: - UI Elements
    
    private lazy var settingsLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textColor = UIColor.etPrimaryLabel
        dateLabel.textAlignment = .center
        dateLabel.text = "Настройки"
        dateLabel.font = AppTextStyle.h2.font
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    
    private  lazy var themetTableViewButton: SettingThemeTableViewButton = {
        let button = SettingThemeTableViewButton(title: SettingsLabel.theme.rawValue)
        button.layer.cornerRadius = 12
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    private  lazy var exportTableViewButton: SettingExportTableViewButton = {
        let button = SettingExportTableViewButton(title: SettingsLabel.exportReport.rawValue)
        return button
    }()
    
    private  lazy var logoutTableViewButton: SettingLogoutTableViewButton = {
        let button = SettingLogoutTableViewButton(title: SettingsLabel.logout.rawValue)
        button.layer.cornerRadius = 12
        button.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .etBackground

        setupViews()
        setupThemeTableViewButton()
        setupExportTableViewButton()
        setupLogoutTableViewButton()
    }
    
    private func setupThemeTableViewButton() {
        logoutTableViewButton.addTarget(self, action: #selector(changeThemeApp), for: .touchUpInside)
    }
    
    private func setupExportTableViewButton() {
        logoutTableViewButton.addTarget(self, action: #selector(exportApp), for: .touchUpInside)
    }
    
    private func setupLogoutTableViewButton() {
        logoutTableViewButton.addTarget(self, action: #selector(logoutApp), for: .touchUpInside)
    }

    private func setupViews() {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(settingsLabel)
        view.addSubview(themetTableViewButton)
        view.addSubview(exportTableViewButton)
        view.addSubview(logoutTableViewButton)

        NSLayoutConstraint.activate([
            settingsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            settingsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            themetTableViewButton.topAnchor.constraint(equalTo: settingsLabel.bottomAnchor, constant: 16),
            themetTableViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            themetTableViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            themetTableViewButton.heightAnchor.constraint(equalToConstant: 48),
            
            exportTableViewButton.topAnchor.constraint(equalTo: themetTableViewButton.bottomAnchor, constant: 1),
            exportTableViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            exportTableViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exportTableViewButton.heightAnchor.constraint(equalToConstant: 48),
            
            logoutTableViewButton.topAnchor.constraint(equalTo: exportTableViewButton.bottomAnchor, constant: 1),
            logoutTableViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutTableViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutTableViewButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc
    private func changeThemeApp() {
        print("changeThemeApp")
    }

    @objc
    private func exportApp() {
        print("exportApp")
    }
    
    @objc
    private func logoutApp() {
        let alert = UIAlertController(
            title: "Выход из аккаунта",
            message: "Вы действительно хотите выйти из аккаунта?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.coordinator?.exit()
        })
        
        present(alert, animated: true)
    }
}
