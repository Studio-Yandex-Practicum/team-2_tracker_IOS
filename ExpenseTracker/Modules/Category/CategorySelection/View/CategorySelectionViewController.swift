import UIKit

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
    private var isAllCategoriesSelected: Bool = false
    private var selectedIndexPath: IndexPath?
    private var categories: [CategoryMain] = CategoryProvider.baseCategories
    private var filteredCategories: [CategoryMain] = []
    private var selectedCategories: Set<String> = []
    private var categoryForExpense = CategoryMain(title: "", icon: Asset.Icon(rawValue: "") ?? .customCat)
//    private var viewModel = CategoryViewModel()
    
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
        tableView.contentInset = UIEdgeInsets(top: 26, left: 0, bottom: 0, right: 0)
        tableView.allowsMultipleSelection = !isSelectionFlow
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let setButton: MainButton = {
        let button = MainButton(title: ButtonAction.set.rawValue)
        button.isEnabled = false
        button.backgroundColor = .etInactive
        return button
    }()
    
    // MARK: - Init
    
    init(isSelectionFlow: Bool) {
        self.isSelectionFlow = isSelectionFlow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToTopOfTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        filteredCategories = categories
        setupSetButton()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .etBackground
        categorySearchBar.delegate = self
        
        setupNavBar()
        setupCategorySearchBar()
        setupViews()
        setupCategoryTableViewButton()
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
        
        NSLayoutConstraint.activate([
            setButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            setButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            setButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryTableViewController.topAnchor.constraint(equalTo: categorySearchBar.bottomAnchor, constant: 16),
            categoryTableViewController.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableViewController.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableViewController.bottomAnchor.constraint(equalTo: setButton.topAnchor, constant: -23),
            
            categoryTableViewButton.topAnchor.constraint(equalTo: categorySearchBar.bottomAnchor, constant: 16),
            categoryTableViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableViewButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupCategoryTableViewButton() {
        if isSelectionFlow {
            categoryTableViewButton.addTargetToIcon(self, action: #selector(showNewCategoryFlow), for: .touchUpInside)
            categoryTableViewButton.addTarget(self, action: #selector(showNewCategoryFlow), for: .touchUpInside)
        } else {
            categoryTableViewButton.addTarget(self, action: #selector(selectAllCategories), for: .touchUpInside)
        }
    }
    
    private func scrollToTopOfTableView() {
        let indexPath = IndexPath(row: 0, section: 0)
        categoryTableViewController.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    private func reloadCells() {
        for case let cell as CategorySelectionCell in categoryTableViewController.visibleCells {
            guard let indexPath = categoryTableViewController.indexPath(for: cell) else { continue }
            
            let isFirst = indexPath.row == 0
            let isLast = indexPath.row == filteredCategories.count - 1
            cell.configure(with: filteredCategories[indexPath.row], isFirst: isFirst, isLast: isLast)
            
            if indexPath.row == categories.count - 1 {
                cell.configure(with: filteredCategories[indexPath.row], isFirst: isFirst, isLast: isLast)
            }
        }
    }
    
    private func setupSetButton() {
        setButton.addTarget(self, action: #selector(setButtonTapped), for: .touchUpInside)
    }
    
    private func updateSetButtonState() {
        let hasSelectedCategories = !selectedCategories.isEmpty
        setButton.isEnabled = hasSelectedCategories
        setButton.backgroundColor = hasSelectedCategories ? .etAccent : .etInactive
    }
    
    @objc
    private func showAddExpenseFlow() {
        coordinator?.dismissCurrentFlow()
    }

    @objc
    private func showNewCategoryFlow() {
        coordinator?.showNewCategoryFlow(with: self)
    }
    
    @objc
    private func setButtonTapped() {
        delegateExpence?.didSelectCategoryForExpense(categoryForExpense)
        delegate?.didSelectCategories(selectedCategories)
        coordinator?.dismissCurrentFlow()
    }
    
    @objc
    private func selectAllCategories() {
        isAllCategoriesSelected.toggle()
        
        for row in categories.indices {
            let indexPath = IndexPath(row: row, section: 0)
            let category = categories[row]
            
            if isAllCategoriesSelected {
                categoryTableViewController.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                selectedCategories.insert(category.title)
                updateCellSelection(at: indexPath, isSelected: true)
            } else {
                categoryTableViewController.deselectRow(at: indexPath, animated: false)
                selectedCategories.remove(category.title)
                updateCellSelection(at: indexPath, isSelected: false)
            }
        }
        updateSetButtonState()
    }
}

// MARK: - UISearchBarDelegate

extension CategorySelectionViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCategories = categories
        } else {
            filteredCategories = categories.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        categoryTableViewButton.isHidden = filteredCategories.isEmpty
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
        cell.configure(with: filteredCategories[indexPath.row], isFirst: isFirst, isLast: isLast)
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
        let category = filteredCategories[indexPath.row]
    
       //  получение категории для трат
        categoryForExpense.title = filteredCategories[indexPath.row].title
        categoryForExpense.icon = filteredCategories[indexPath.row].icon
        selectedCategories.insert(category.title)
        updateCellSelection(at: indexPath, isSelected: true)
        
        if isSelectionFlow {
            if let previousIndexPath = selectedIndexPath, previousIndexPath != indexPath {
                updateCellSelection(at: previousIndexPath, isSelected: false)
            }
            selectedIndexPath = indexPath
            
        }
        updateSetButtonState()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if !isSelectionFlow {
            let category = filteredCategories[indexPath.row]
            selectedCategories.remove(category.title)
            updateCellSelection(at: indexPath, isSelected: false)
            updateSetButtonState()
        }
    }

    private func updateCellSelection(at indexPath: IndexPath, isSelected: Bool) {
        guard let cell = categoryTableViewController.cellForRow(at: indexPath) as? CategorySelectionCell else { return }
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == filteredCategories.count - 1
        cell.configure(with: filteredCategories[indexPath.row], isFirst: isFirst, isLast: isLast)
    }
}

extension CategorySelectionViewController: CreateCategoryDelegate {
    func createcategory(_ newCategory: CategoryMain) {
        categories.append(newCategory)
        filteredCategories = categories
        categoryTableViewController.reloadData()
    }
}
    
