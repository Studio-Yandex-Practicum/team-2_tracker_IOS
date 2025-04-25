import UIKit

final class CategorySelectionViewController: UIViewController {
    
    // MARK: - Private Properties
    
    weak var coordinator: ExpensesCoordinator?
    
    private var isSelectionFlow: Bool
    private var customNavigationBar: CustomBackBarItem?
    private var isAllCategoriesSelected: Bool = false
    private var selectedIndexPath: IndexPath?
    private let categories: [CategoryMain] = CategoryProvider.baseCategories
    
    // MARK: - UI Elements
    
    private let categorySearchBar: MainSearchBar = {
        let searchBar = MainSearchBar()
        searchBar.placeholder = CategoryLabel.categorySearch.rawValue
        return searchBar
    }()
    
    private lazy var categoryTableViewButton: CategoryTableViewButton = {
        let button = isSelectionFlow ? CategoryTableViewButton(title: CategoryLabel.createCategory.rawValue, isShownButton: isSelectionFlow) : CategoryTableViewButton(title: CategoryLabel.allCategories.rawValue, isShownButton: isSelectionFlow)
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
        tableView.contentInset = UIEdgeInsets(top: 48, left: 0, bottom: 0, right: 0)
        tableView.allowsMultipleSelection = !isSelectionFlow
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let setButton: MainButton = MainButton(title: ButtonAction.set.rawValue)
    
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
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .etBackground
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
            let model = categories[indexPath.row]
            cell.configure(
                with: model
            )
            if indexPath.row == categories.count - 1 {
                cell.setupLastCell()
            }
        }
    }
    
    @objc
    private func showAddExpenseFlow() {
        coordinator?.dismissCurrentFlow()
    }
    
    @objc
    private func showNewCategoryFlow() {
        coordinator?.showNewCategoryFlow()
    }
    
    @objc
    private func selectAllCategories() {
        isAllCategoriesSelected.toggle()
        
        for row in categories.indices {
            let indexPath = IndexPath(row: row, section: 0)
            
            if isAllCategoriesSelected {
                categoryTableViewController.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                updateCellSelection(at: indexPath, isSelected: true)
            } else {
                categoryTableViewController.deselectRow(at: indexPath, animated: false)
                updateCellSelection(at: indexPath, isSelected: false)
            }
        }
    }
}

extension CategorySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectionCell.reuseIdentifier, for: indexPath) as? CategorySelectionCell else {
            return UITableViewCell()
        }
        cell.configure(with: categories[indexPath.row])
        
        if indexPath.row == categories.count - 1 {
            cell.setupLastCell()
        }
        return cell
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateCellSelection(at: indexPath, isSelected: true)
        
        if isSelectionFlow {
            if let previousIndexPath = selectedIndexPath, previousIndexPath != indexPath {
                updateCellSelection(at: previousIndexPath, isSelected: false)
            }
            selectedIndexPath = indexPath
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if !isSelectionFlow {
            updateCellSelection(at: indexPath, isSelected: false)
        }
    }

    private func updateCellSelection(at indexPath: IndexPath, isSelected: Bool) {
        guard let cell = categoryTableViewController.cellForRow(at: indexPath) as? CategorySelectionCell else { return }
        let category = categories[indexPath.row]
        cell.configure(with: category)
    }
}
