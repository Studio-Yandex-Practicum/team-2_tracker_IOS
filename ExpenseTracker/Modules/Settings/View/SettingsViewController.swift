import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SettingsCoordinator?
    private let settingsService: SettingsService
    
    init() {
        self.settingsService = SettingsService()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private lazy var themetTableViewButton: SettingThemeTableViewButton = {
        let button = SettingThemeTableViewButton(title: SettingsLabel.theme.rawValue)
        button.layer.cornerRadius = 12
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var exportTableViewButton: SettingExportTableViewButton = {
        let button = SettingExportTableViewButton(title: SettingsLabel.exportReport.rawValue)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var logoutTableViewButton: SettingLogoutTableViewButton = {
        let button = SettingLogoutTableViewButton(title: SettingsLabel.logout.rawValue)
        button.layer.cornerRadius = 12
        button.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .etBackground
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Private Methods
    
    private func setupUI() {
        setupViews()
        setupExportTableViewButton()
        setupLogoutTableViewButton()
    }
    
    private func setupExportTableViewButton() {
        exportTableViewButton.addTarget(self, action: #selector(exportReport), for: .touchUpInside)
    }
    
    private func setupLogoutTableViewButton() {
        logoutTableViewButton.addTarget(self, action: #selector(logoutApp), for: .touchUpInside)
    }

    private func setupViews() {
        view.addSubview(settingsLabel)
        view.addSubview(themetTableViewButton)
        view.addSubview(exportTableViewButton)
        view.addSubview(logoutTableViewButton)

        NSLayoutConstraint.activate([
            settingsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
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
    
    @objc
    private func exportReport() {
        switch settingsService.exportExpensesToCSV() {
        case .success(let fileURL):
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = exportTableViewButton
                popoverController.sourceRect = exportTableViewButton.bounds
            }
            present(activityVC, animated: true)
            
        case .failure(let error):
            print("Ошибка при создании CSV файла: \(error)")
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Не удалось создать файл отчета",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
