import UIKit
import CoreData

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategories(_ categories: Set<String>)
}

protocol CategoryForExpenseDelegate: AnyObject {
    func didSelectCategoryForExpense(_ categories: CategoryMain)
}

final class CategorySelectionViewController: UIViewController {
    
    // MARK: - Private Properties
    
    weak var coordinator: ExpensesCoordinator?
    weak var delegate: CategorySelectionDelegate?
    weak var delegateExpence: CategoryForExpenseDelegate?
    
    private var isSelectionFlow: Bool
    private var customNavigationBar: CustomBackBarItem?
    private var categories: [CategoryMain] = []
    private let categoryService: CategoryService
    private var isAllCategoriesSelected: Bool = false
    private var selectedIndexPath: IndexPath?
    private var filteredCategories: [CategoryMain] = []
    private var selectedCategories: Set<String> = []
    private var categoryForExpense = CategoryMain(title: "", icon: Asset.Icon(rawValue: "") ?? .other)
    
    // MARK: - UI Elements
    
    private let categorySearchBar: MainSearchBar = {
        let searchBar = MainSearchBar()
        searchBar.placeholder = CategoryLabel.categorySearch.rawValue
        return searchBar
    }()
    
    private lazy var categoryTableViewButton: CategoryTableViewButton = {
        let button = isSelectionFlow ? CategoryTableViewButton(title: CategoryLabel.createCategory.rawValue, isShownButton: isSelectionFlow) : CategoryTableViewButton(title: CategoryLabel.allCategories.rawValue, isShownButton: isSelectionFlow)
        button.layer.cornerRadius = 12
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] 
        return button
    }()
    
    private lazy var categoryTableViewController: UITableView = {
        let tableView = UITableView()
        tableView.register(CategorySelectionCell.self, forCellReuseIdentifier: CategorySelectionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 12
        tableView.separatorStyle = .none
        tableView.backgroundColor = .etBackground
        tableView.contentInset = .zero
        tableView.allowsMultipleSelection = !isSelectionFlow
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Asset.Icon.checkboxPressed.rawValue)
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let setButton: MainButton = {
        let button = MainButton(title: ButtonAction.set.rawValue)
        button.isEnabled = false
        button.backgroundColor = .etInactive
        return button
    }()
    
    // MARK: - Init
    
    init(isSelectionFlow: Bool, context: NSManagedObjectContext) {
        self.isSelectionFlow = isSelectionFlow
        self.categoryService = CategoryService(context: context)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCategories()
        filteredCategories = categories
        
        // Загружаем сохраненные категории и состояние кнопки "Все категории"
        if !isSelectionFlow {
            if let savedCategories = UserDefaults.standard.array(forKey: "selectedCategories") as? [String] {
                selectedCategories = Set(savedCategories)
            }
            
            // Проверяем, было ли сохранено состояние "Все категории"
            let isAllCategoriesSelected = UserDefaults.standard.bool(forKey: "isAllCategoriesSelected")
            if isAllCategoriesSelected {
                checkmarkImageView.isHidden = false
                selectedCategories = Set(categories.map(\.title))
            } else {
                checkmarkImageView.isHidden = true
            }
        }
        
        setupSetButton()
        setupCategoryTableViewButton()
        categoryTableViewController.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        categorySearchBar.delegate = self
        
        setupNavBar()
        setupCategorySearchBar()
        setupViews()
        setupTapGesture()
    }

    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        customNavigationBar = setupCustomNavBar(title: CategoryLabel.selectCategory.rawValue, backAction: #selector(showAddExpenseFlow))
    }
    
    private func setupCategorySearchBar() {
        guard let customNavigationBar = customNavigationBar else { return }
        view.addSubview(categorySearchBar)
        
        NSLayoutConstraint.activate([
            categorySearchBar.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: 16),
            categorySearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            categorySearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupViews() {
        [setButton, categoryTableViewController, categoryTableViewButton].forEach {
            view.addSubview($0)
        }
        
        categoryTableViewButton.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            setButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            setButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            setButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryTableViewController.topAnchor.constraint(equalTo: categorySearchBar.bottomAnchor, constant: 40),
            categoryTableViewController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableViewController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableViewController.bottomAnchor.constraint(equalTo: setButton.topAnchor, constant: -23),
            
            categoryTableViewButton.topAnchor.constraint(equalTo: categorySearchBar.bottomAnchor, constant: 16),
            categoryTableViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableViewButton.heightAnchor.constraint(equalToConstant: 48),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: categoryTableViewButton.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: categoryTableViewButton.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupCategoryTableViewButton() {
        if isSelectionFlow {
            categoryTableViewButton.addTargetToIcon(self, action: #selector(showNewCategoryFlow), for: .touchUpInside)
            categoryTableViewButton.addTarget(self, action: #selector(showNewCategoryFlow), for: .touchUpInside)
        } else {
            categoryTableViewButton.addTarget(self, action: #selector(allCategoriesButtonTapped), for: .touchUpInside)
        }
    }
    
    private func scrollToTopOfTableView() {
        guard !filteredCategories.isEmpty else { return }
        let indexPath = IndexPath(row: 0, section: 0)
        categoryTableViewController.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    private func reloadCells() {
        for case let cell as CategorySelectionCell in categoryTableViewController.visibleCells {
            guard let indexPath = categoryTableViewController.indexPath(for: cell) else { continue }
            let isFirst = indexPath.row == 0
            let isLast = indexPath.row == filteredCategories.count - 1
            cell.configure(with: filteredCategories[indexPath.row], isFirst: isFirst, isLast: isLast)
            
            // Обновляем скругление углов для последней ячейки
            if isLast {
                cell.layer.cornerRadius = 12
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.cornerRadius = 0
                cell.layer.maskedCorners = []
            }
        }
    }
    
    private func setupSetButton() {
        setButton.addTarget(self, action: #selector(setButtonTapped), for: .touchUpInside)
    }
    
    private func updateSetButtonState() {
        let validate = !selectedCategories.isEmpty && selectedIndexPath != nil
        setButton.isEnabled = validate || !checkmarkImageView.isHidden
        setButton.backgroundColor = validate || !checkmarkImageView.isHidden ? .etAccent : .etInactive
    }
    
    private func setupCheckBox() {
        checkmarkImageView.isHidden.toggle()
        if !checkmarkImageView.isHidden {
            selectedCategories = Set(categories.map(\.title))
        } else {
            selectedCategories = []
        }
    }
    
    private func deselectAllCells() {
        for indexPath in categoryTableViewController.indexPathsForSelectedRows ?? [] {
            categoryTableViewController.deselectRow(at: indexPath, animated: true)
        }
        reloadCells()
    }
    
    private func prepareForTransition() {
        categoryTableViewButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        categoryTableViewButton.showSeparator()
        categorySearchBar.text = ""
        categorySearchBar.resignFirstResponder()
    }
    
    @objc
    private func showAddExpenseFlow() {
        coordinator?.dismissCurrentFlow()
    }

    @objc
    private func showNewCategoryFlow() {
        prepareForTransition()
        coordinator?.showNewCategoryFlow(with: self)
    }
    
    @objc
    private func setButtonTapped() {
        if isSelectionFlow {
            delegateExpence?.didSelectCategoryForExpense(categoryForExpense)
        } else {
            // Сохраняем выбранные категории и состояние кнопки "Все категории"
            UserDefaults.standard.set(Array(selectedCategories), forKey: "selectedCategories")
            UserDefaults.standard.set(!checkmarkImageView.isHidden, forKey: "isAllCategoriesSelected")
            delegate?.didSelectCategories(selectedCategories)
        }
        coordinator?.dismissCurrentFlow()
    }
    
    @objc
    private func allCategoriesButtonTapped() {
        setupCheckBox()
        deselectAllCells()
        
        // Обновляем состояние в UserDefaults
        if !checkmarkImageView.isHidden {
            // Если выбраны все категории
            UserDefaults.standard.set(true, forKey: "isAllCategoriesSelected")
            UserDefaults.standard.removeObject(forKey: "selectedCategories")
            selectedCategories = Set(categories.map(\.title))
        } else {
            // Если отменен выбор всех категорий
            UserDefaults.standard.set(false, forKey: "isAllCategoriesSelected")
            UserDefaults.standard.removeObject(forKey: "selectedCategories")
            selectedCategories = []
        }
        
        updateSetButtonState()
    }
    
    private func loadCategories() {
        let categoryModels = categoryService.fetchAllCategories()
        categories = categoryModels.map { model in
            CategoryMain(
                title: model.name ?? "",
                icon: Asset.Icon(rawValue: model.icon ?? "") ?? .other
            )
        }
    }
}

// MARK: - UISearchBarDelegate

extension CategorySelectionViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCategories = categories
        } else {
            filteredCategories = categories.filter { $0.title.lowercased().contains(searchText.lowercased())
            }
        }
        
        if filteredCategories.isEmpty {
            categoryTableViewButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            categoryTableViewButton.hideSeparator()
        } else {
            categoryTableViewButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            categoryTableViewButton.showSeparator()
        }
        
        categoryTableViewController.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CategorySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectionCell.reuseIdentifier, for: indexPath) as? CategorySelectionCell else {
            return UITableViewCell()
        }
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == filteredCategories.count - 1
        let category = filteredCategories[indexPath.row]
        cell.configure(with: category, isFirst: isFirst, isLast: isLast)
        
        // Обновляем скругление углов
        if isLast {
            cell.layer.cornerRadius = 12
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
        }
        
        // Если выбраны все категории, не отмечаем отдельные ячейки
        if !isSelectionFlow && !checkmarkImageView.isHidden {
            cell.isCellSelected = false
            tableView.deselectRow(at: indexPath, animated: false)
        } else if !isSelectionFlow && selectedCategories.contains(category.title) {
            cell.isCellSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategorySelectionCell else {
            return
        }
        
        if isSelectionFlow {
            if selectedIndexPath != nil {
                selectedIndexPath = nil
            } else {
                selectedIndexPath = indexPath
            }
        } else {
            selectedIndexPath = indexPath
        }
        
        let categoryTitle = categories[indexPath.row].title
        let categoryIcon = categories[indexPath.row].icon
        categoryForExpense = CategoryMain(title: categoryTitle, icon: categoryIcon)
        
        if !checkmarkImageView.isHidden {
            selectedCategories = []
        }
        checkmarkImageView.isHidden = true
        
        let selectedCategory = categories[indexPath.row]
        
        selectedCategories.insert(selectedCategory.title)
        cell.isCellSelected.toggle()
        updateSetButtonState()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategorySelectionCell else {
            return
        }
        let selectedCategory = categories[indexPath.row]
        
        if isSelectionFlow {
            selectedIndexPath = nil
            cell.isCellSelected = false
        } else {
            selectedCategories.remove(selectedCategory.title)
            cell.isCellSelected.toggle()
            updateSetButtonState()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isSelectionFlow else { return nil }
        
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            
            let category = self.categories[indexPath.row]
            
            // Проверяем, есть ли связанные расходы
            let hasExpenses = self.categoryService.hasRelatedExpenses(category)
            
            let alert = UIAlertController(
                title: "Удалить категорию",
                message: hasExpenses ? "Данная категория имеет записи расходов. В случае удаления, все данные будут потеряны." : "Вы уверены, что хотите удалить данную категорию?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            alert.addAction(
                UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    
                    do {
                        // Удаляем категорию и связанные расходы
                        if try self.categoryService.deleteCategory(category) {
                            // Удаляем категорию из массива
                            self.categories.remove(at: indexPath.row)
                            self.filteredCategories = self.categories
                            
                            // Обновляем таблицу
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            reloadCells()
                            // Если удалили выбранную категорию, сбрасываем выбор
                            if self.selectedIndexPath == indexPath {
                                self.selectedIndexPath = nil
                                self.updateSetButtonState()
                            }
                        }
                    } catch {
                        print("Error deleting category: \(error)")
                        // Показываем ошибку пользователю
                        let errorAlert = UIAlertController(
                            title: "Ошибка",
                            message: "Не удалось удалить категорию",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                })
            self.present(alert, animated: true)
            completion(true)
        }
        delete.image = UIImage(named: "delete")?.withTintColor(.etButtonLabel)
        delete.backgroundColor = UIColor.etbRed
        
        let edit = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            
            // Получаем категорию для редактирования
            let category = self.categories[indexPath.row]
            
            // Показываем экран редактирования категории
            self.coordinator?.showEditCategoryFlow(with: self, category: category)
            
            completion(true)
        }
        
        edit.image = UIImage(named: "edit")?.withTintColor(.etButtonLabel)
        edit.backgroundColor = UIColor.etOrange
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}

extension CategorySelectionViewController: CreateCategoryDelegate {
    func createcategory(_ newCategory: CategoryMain) {
        // Перезагружаем все категории из базы данных
        loadCategories()
        
        // Обновляем отфильтрованные категории
        if categorySearchBar.text?.isEmpty ?? true {
            filteredCategories = categories
        } else {
            filteredCategories = categories.filter { $0.title.lowercased().contains(categorySearchBar.text?.lowercased() ?? "") }
        }
        
        // Обновляем таблицу
        categoryTableViewController.reloadData()
    }
}
