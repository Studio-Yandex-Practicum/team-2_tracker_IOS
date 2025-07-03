import UIKit

final class MainSearchBar: UISearchBar {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Layout
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Constants.defaultHeight)
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        setupSearchBar()
        setupTextField()
        setupBookmarkButton()
        setupBackgroundImage()
    }
    
    private func setupSearchBar() {
        backgroundImage = UIImage()
        translatesAutoresizingMaskIntoConstraints = false
        showsBookmarkButton = true
    }
    
    private func setupTextField() {
        let textField = searchTextField
        textField.backgroundColor = .etCardsToggled
        textField.textColor = .etCards
        textField.font = AppTextStyle.body.font
        textField.layer.cornerRadius = Constants.defaultCornerRadius
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = Constants.defaultBorderWidth
        textField.layer.borderColor = UIColor.clear.cgColor
        
        textField.leftView = makePaddingView()
        textField.leftViewMode = .always
        textField.clearButtonMode = .never
        textField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [.foregroundColor: UIColor.etSecondaryLabel]
        )
    }
    
    private func setupBookmarkButton() {
        let searchImage = UIImage(named: Asset.Icon.search.rawValue)?
            .withTintColor(.etSecondaryLabel, renderingMode: .alwaysOriginal)
        
        setImage(searchImage, for: .bookmark, state: .normal)
    }
    
    private func setupBackgroundImage() {
        let clearImage = getImageWithColor(color: .clear, size: CGSize(width: 1, height: Constants.defaultHeight))
        setSearchFieldBackgroundImage(clearImage, for: .normal)
    }
    
    private func makePaddingView() -> UIView {
        UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
    }
    
    private func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    private enum Constants {
        static let defaultCornerRadius: CGFloat = 12
        static let defaultBorderWidth: CGFloat = 1
        static let paddingWidth: CGFloat = 16
        static let defaultHeight: CGFloat = 48
    }
}
