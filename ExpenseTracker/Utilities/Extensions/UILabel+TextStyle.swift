import UIKit

extension UILabel {
    func applyTextStyle(_ style: AppTextStyle, textStyle: UIFont.TextStyle) {
        let font = dynamicFont(for: style, textStyle: textStyle)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.maximumLineHeight = style.lineHeight

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .kern: style.letterSpacing,
            .paragraphStyle: paragraphStyle
        ]

        let attributedText = NSAttributedString(string: self.text ?? "", attributes: attributes)
        self.attributedText = attributedText
        self.adjustsFontForContentSizeCategory = true
    }
    
    func dynamicFont(for style: AppTextStyle, textStyle: UIFont.TextStyle) -> UIFont {
        let baseFont = style.font
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: baseFont)
    }
}
