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
        view.addSubview(logoutTableViewButton)
        view.addSubview(settingTableViewController)
        
//        [settingTableViewController, logoutTableViewButton].forEach {
//            view.addSubview($0)
//        }
        
        NSLayoutConstraint.activate([
            settingsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            settingsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            settingTableViewController.topAnchor.constraint(equalTo: settingsLabel.bottomAnchor, constant: 16),
            settingTableViewController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingTableViewController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            logoutTableViewButton.topAnchor.constraint(equalTo: settingsLabel.bottomAnchor, constant: 16),
            logoutTableViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutTableViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutTableViewButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    
    @objc
    private func logoutApp() {
        
        print("exit")
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


