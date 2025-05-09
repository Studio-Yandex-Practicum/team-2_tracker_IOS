import UIKit

protocol CreateCategoryDelegate: AnyObject {
    func createcategory(_ newCategory: CategoryMain)
}

final class NewCategoryViewController: UIViewController {
    
    weak var delegate: CreateCategoryDelegate?
    weak var coordinator: ExpensesCoordinator?
    
    private var newCategoryView: String = ""
    private let icons: [String] = (0...12).map { String($0) }
    private var selectedIndexPath: IndexPath?
    private var customNavigationBar: CustomBackBarItem?

    private let newCategoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var newCategoryTextField: MainTextField = {
        let textField = MainTextField(placeholder: CategoryLabel.categoryName.rawValue)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var categoryIconsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryIconCell.self, forCellWithReuseIdentifier: CategoryIconCell.identifier)
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .etCardsToggled
        collectionView.layer.cornerRadius = 12
        collectionView.contentInset = UIEdgeInsets(top: 4, left: 18, bottom: 12, right: 28)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalToConstant: (view.frame.width - 32) / 1.5).isActive = true
        return collectionView
    }()
    
    private let saveButton: MainButton = {
        let button = MainButton(title: ButtonAction.save.rawValue)
        button.isEnabled = false
        button.backgroundColor = .etInactive
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSaveCategoryButton()
    }

    private func setupUI() {
        view.backgroundColor = .etBackground
        setupNavBar()
        setupNewCategoryStackView()
        setupSaveButton()
        setupTapGesture()
    }

    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        customNavigationBar = setupCustomNavBar(title: CategoryLabel.createCategory.rawValue, backAction: #selector(backTo))
    }

    private func setupNewCategoryStackView() {
        guard let customNavigationBar = customNavigationBar else { return }
        view.addSubview(newCategoryStackView)
        newCategoryStackView.addArrangedSubview(newCategoryTextField)
        newCategoryStackView.addArrangedSubview(categoryIconsCollectionView)

        NSLayoutConstraint.activate([
            newCategoryStackView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor, constant: 20),
            newCategoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupSaveButton() {
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSaveCategoryButton() {
        saveButton.addTarget(self, action: #selector(saveNewCategory), for: .touchUpInside)
    }
    
    func updateSaveButton() {
        guard
            let categoryName = newCategoryTextField.text,
            let categoryIconSelected = selectedIndexPath
        else { return }
       
        let categoryNameWithoutSpaces = categoryName.replacingOccurrences(of: " ", with: "")
        saveButton.isEnabled = !categoryNameWithoutSpaces.isEmpty
        saveButton.backgroundColor = !categoryNameWithoutSpaces.isEmpty ? .etAccent : .etInactive
    }
    
    @objc
    private func textFieldDidChange() {
        updateSaveButton()
    }
    
    @objc
    private func saveNewCategory() {
        guard
            let categoryName = newCategoryTextField.text,
            let categoryIcon = Asset.Icon(rawValue: newCategoryView)
        else { return }
        
        let categoryNameWithoutSpaces = categoryName.replacingOccurrences(of: " ", with: "")
        let newCategory = CategoryMain(title: categoryNameWithoutSpaces, icon: categoryIcon)
        
        delegate?.createcategory(newCategory)
        coordinator?.dismissCurrentFlow()
    }

    @objc
    private func backTo() {
        coordinator?.dismissCurrentFlow()
    }  
}

extension NewCategoryViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        icons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryIconCell.identifier, for: indexPath) as? CategoryIconCell else {
            return UICollectionViewCell()
        }
        let isSelected = indexPath == selectedIndexPath
        cell.configure(with: icons[indexPath.row], selected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath != indexPath {
            let previousIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            collectionView.reloadItems(at: [indexPath] + (previousIndexPath.map { [$0] } ?? []))
            newCategoryView = icons[indexPath.row]
        }
        updateSaveButton()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 44, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryHeaderView.identifier, for: indexPath) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
}
