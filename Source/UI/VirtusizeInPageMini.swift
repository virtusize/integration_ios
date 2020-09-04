//
//  VirtusizeInPageMini.swift
//
//  Copyright (c) 2020 Virtusize KK
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/// TODO: Comment
public class VirtusizeInPageMini: VirtusizeInPageView {

    public var inPageMiniBackgroundColor: UIColor? {
        didSet {
            setStyle()
        }
    }

    private let horizontalEdgeMargin: CGFloat = 8
    private let messageAndButtonMargin: CGFloat = 8
    private let verticalMargin: CGFloat = 5

    private let inPageMiniMessageLabel: UILabel = UILabel()
    private let inPageMiniSizeCheckButton: UIButton = UIButton()

    public func setupHorizontalMargin(view: UIView, margin: CGFloat) {
        setHorizontalMargins(view: view, margin: margin)
    }

    internal override func setup() {
        addSubviews()
        setConstraints()
        setStyle()

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openVirtusizeWebView)))
        inPageMiniSizeCheckButton.addTarget(self, action: #selector(openVirtusizeWebView), for: .touchUpInside)
    }

    public override func setupProductDataCheck() {
        guard let product = Virtusize.product else {
            return
        }

        setupInPageText(product: product, onCompletion: { storeProduct, i18nLocalization in
            self.inPageMiniMessageLabel.attributedText = NSAttributedString(string:
                storeProduct.getRecommendationText(i18nLocalization: i18nLocalization)
            ).lineSpacing(self.verticalMargin/2)
            self.isHidden = false
        })
    }

    private func addSubviews() {
        addSubview(inPageMiniMessageLabel)
        addSubview(inPageMiniSizeCheckButton)
    }

    private func setConstraints() {
        inPageMiniMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        inPageMiniSizeCheckButton.translatesAutoresizingMaskIntoConstraints = false

        let views = ["messageLabel": inPageMiniMessageLabel, "sizeCheckButton": inPageMiniSizeCheckButton]
        let metrics = [
            "horizontalEdgeMargin": horizontalEdgeMargin,
            "verticalMargin": verticalMargin,
            "messageAndButtonMargin": messageAndButtonMargin
        ]

        // swiftlint:disable line_length
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-horizontalEdgeMargin-[messageLabel]-(>=messageAndButtonMargin)-[sizeCheckButton]-(horizontalEdgeMargin)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        let messageLabelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-verticalMargin-[messageLabel]-verticalMargin-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        let sizeCheckButtonVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=verticalMargin)-[sizeCheckButton]-(>=verticalMargin)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        addConstraints(horizontalConstraints)
        addConstraints(messageLabelVerticalConstraints)
        addConstraints(sizeCheckButtonVerticalConstraints)
        addConstraint(inPageMiniSizeCheckButton.centerYAnchor.constraint(equalTo: self.centerYAnchor))
    }

    // swiftlint:disable function_body_length
    private func setStyle() {
        if inPageMiniBackgroundColor != nil {
            backgroundColor = inPageMiniBackgroundColor
        } else if style == .TEAL {
            backgroundColor = Colors.vsTealColor
        } else {
            backgroundColor = Colors.gray900Color
        }

        inPageMiniMessageLabel.numberOfLines = 0
        inPageMiniMessageLabel.textColor = UIColor.white
        inPageMiniMessageLabel.setContentHuggingPriority(.required, for: .horizontal)

        inPageMiniSizeCheckButton.backgroundColor = UIColor.white
        inPageMiniSizeCheckButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 6)
        inPageMiniSizeCheckButton.setTitle(Localization.shared.localize("check_size"), for: .normal)
        let displayLanguage = Virtusize.params?.language
        switch displayLanguage {
        case .ENGLISH:
            inPageMiniMessageLabel.font = Font.proximaNova(size: 14)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.proximaNova(size: 12)
        case .JAPANESE:
            inPageMiniMessageLabel.font = Font.notoSansCJKJP(size: 12)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.notoSansCJKJP(size: 10)
        case .KOREAN:
            inPageMiniMessageLabel.font = Font.notoSansCJKKR(size: 12)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.notoSansCJKKR(size: 10)
        default:
            inPageMiniMessageLabel.font = Font.proximaNova(size: 14)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.proximaNova(size: 12)
        }

        inPageMiniSizeCheckButton.layer.cornerRadius = inPageMiniSizeCheckButton.intrinsicContentSize.height / 2

        let rightArrowImageTemplate = Assets.rightArrow?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        inPageMiniSizeCheckButton.setImage(rightArrowImageTemplate, for: .normal)
        inPageMiniSizeCheckButton.setImage(rightArrowImageTemplate, for: .highlighted)
        inPageMiniSizeCheckButton.semanticContentAttribute = .forceRightToLeft
        if inPageMiniBackgroundColor != nil {
            inPageMiniSizeCheckButton.setTitleColor(inPageMiniBackgroundColor, for: .normal)
            inPageMiniSizeCheckButton.imageView?.tintColor = inPageMiniBackgroundColor
        } else if style == .TEAL {
            inPageMiniSizeCheckButton.setTitleColor(Colors.vsTealColor, for: .normal)
            inPageMiniSizeCheckButton.imageView?.tintColor = Colors.vsTealColor
        } else {
            inPageMiniSizeCheckButton.setTitleColor(Colors.gray900Color, for: .normal)
            inPageMiniSizeCheckButton.imageView?.tintColor = Colors.gray900Color
        }
        inPageMiniSizeCheckButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
