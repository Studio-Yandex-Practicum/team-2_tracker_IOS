import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: SettingsCoordinator?
    private let settingsService: SettingsService
    private var customNavigationBar: CustomBackBarItem?
    
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
    
    private lazy var exportButton: SettingTableViewButton = {
        let button = SettingTableViewButton(title: "Экспорт данных")
        button.layer.cornerRadius = 12
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return button
    }()
    
    private lazy var themeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .etBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Темная тема"
        label.textColor = .etPrimaryLabel
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var themeSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .systemBlue
        switchControl.isOn = traitCollection.userInterfaceStyle == .dark
        switchControl.addTarget(self, action: #selector(themeSwitchChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private  lazy var logoutTableViewButton: SettingTableViewButton = {
        let button = SettingTableViewButton(title: SettingsLabel.logout.rawValue)
        button.layer.cornerRadius = 12
     //   button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return button
    }()
    
    private lazy var settingTableViewController: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 12
     //   tableView.separatorStyle = .none
        tableView.backgroundColor = .etBackground
        tableView.contentInset = UIEdgeInsets(top: 26, left: 0, bottom: 0, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Загружаем сохраненную тему
        let isDarkTheme = UserDefaults.standard.bool(forKey: "isDarkTheme")
        themeSwitch.isOn = isDarkTheme
        themeLabel.text = isDarkTheme ? "Темная тема" : "Светлая тема"
    }

    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .etBackground

        setupViews()
        setupCategoryTableViewButton()
    }

    
    private func setupCategoryTableViewButton() {
        logoutTableViewButton.addTarget(self, action: #selector(logoutApp), for: .touchUpInside)
    }

    private func setupViews() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(settingsLabel)
        view.addSubview(exportButton)
        view.addSubview(themeContainer)
        themeContainer.addSubview(themeLabel)
        themeContainer.addSubview(themeSwitch)
        view.addSubview(logoutTableViewButton)
        view.addSubview(settingTableViewController)
        
        // Добавляем обработчик нажатия для кнопки экспорта
        exportButton.addTarget(self, action: #selector(exportReport), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            settingsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            settingsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            exportButton.topAnchor.constraint(equalTo: settingsLabel.bottomAnchor, constant: 16),
            exportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            exportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exportButton.heightAnchor.constraint(equalToConstant: 48),
            
            themeContainer.topAnchor.constraint(equalTo: exportButton.bottomAnchor),
            themeContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            themeContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            themeContainer.heightAnchor.constraint(equalToConstant: 48),
            
            themeLabel.leadingAnchor.constraint(equalTo: themeContainer.leadingAnchor, constant: 16),
            themeLabel.centerYAnchor.constraint(equalTo: themeContainer.centerYAnchor),
            
            themeSwitch.trailingAnchor.constraint(equalTo: themeContainer.trailingAnchor, constant: -16),
            themeSwitch.centerYAnchor.constraint(equalTo: themeContainer.centerYAnchor),
            
            logoutTableViewButton.topAnchor.constraint(equalTo: themeContainer.bottomAnchor),
            logoutTableViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutTableViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutTableViewButton.heightAnchor.constraint(equalToConstant: 48),
            
            settingTableViewController.topAnchor.constraint(equalTo: logoutTableViewButton.bottomAnchor, constant: 16),
            settingTableViewController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingTableViewController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingTableViewController.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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
    private func themeSwitchChanged(_ sender: UISwitch) {
        // Сохраняем выбранную тему в UserDefaults
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkTheme")
        UserDefaults.standard.synchronize()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
            }
        }
        themeLabel.text = sender.isOn ? "Темная тема" : "Светлая тема"
    }
    
    @objc
    private func exportReport() {
        print("Нажата кнопка экспорта") // Добавляем для отладки
        
        switch settingsService.exportExpensesToCSV() {
        case .success(let fileURL):
            // Создаем UIActivityViewController
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            // Показываем UIActivityViewController
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = exportButton
                popoverController.sourceRect = exportButton.bounds
            }
            
            present(activityVC, animated: true)
            
        case .failure(let error):
            print("Ошибка при создании CSV файла: \(error)")
            // Показываем алерт с ошибкой
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
// MARK: - UITableViewDelegate & UITableViewDataSource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
       
        return cell
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? CategorySelectionCell else {
//            return
//        }
//        selectedIndexPath = indexPath
//        
//        let categoryTitle = categories[indexPath.row].title
//        let categoryIcon = categories[indexPath.row].icon
//        categoryForExpense = CategoryMain(title: categoryTitle, icon: categoryIcon)
//        
//        if !checkmarkImageView.isHidden {
//            selectedCategories = []
//        }
//        checkmarkImageView.isHidden = true
//        
//        let selectedCategory = categories[indexPath.row]
//        selectedCategories.insert(selectedCategory.title)
//        cell.isCellSelected.toggle()
//        updateSetButtonState()
//    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? CategorySelectionCell else {
//            return
//        }
//        let selectedCategory = categories[indexPath.row]
//        
//        if isSelectionFlow {
//            cell.isCellSelected = false
//        } else {
//            selectedCategories.remove(selectedCategory.title)
//            cell.isCellSelected.toggle()
//            updateSetButtonState()
//        }
//    }
}


