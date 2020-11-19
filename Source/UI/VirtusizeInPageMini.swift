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

/// This class is the custom Virtusize InPage Mini view that can be added in the client's layout file.
public class VirtusizeInPageMini: VirtusizeInPageView {

    /// The property to set the background color of the InPage Mini view
    public var inPageMiniBackgroundColor: UIColor? {
        didSet {
            setStyle()
        }
    }

    private let messageAndButtonMargin: CGFloat = 8
    private let verticalMargin: CGFloat = 5

    private let inPageMiniImageView: UIImageView = UIImageView()
    private let inPageMiniMessageLabel: UILabel = UILabel()
    private let inPageMiniSizeCheckButton: UIButton = UIButton()

    /// The function to set the horizontal margin between the edges of the app screen and the InPage Mini view
    public func setupHorizontalMargin(view: UIView, margin: CGFloat) {
        setHorizontalMargins(view: view, margin: margin)
    }

    internal override func setup() {
        addSubviews()
        setConstraints()
        setStyle()

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickInPageViewAction)))
        inPageMiniSizeCheckButton.addTarget(self, action: #selector(clickInPageViewAction), for: .touchUpInside)
    }

    public override func isLoading() {
        super.isLoading()
        setLoadingScreen(loading: true)
    }

    public override func updateInPageTextAndView() {
		super.updateInPageTextAndView()

        setLoadingScreen(loading: false)
        inPageMiniMessageLabel.attributedText = NSAttributedString(string:
		    Virtusize.storeProduct!.getRecommendationText(
				Virtusize.i18nLocalization!,
				Virtusize.sizeComparisonRecommendedSize,
				Virtusize.bodyProfileRecommendedSize?.sizeName,
                VirtusizeI18nLocalization.TrimType.ONELINE
            )
        ).lineSpacing(self.verticalMargin/2)
    }

    private func addSubviews() {
        addSubview(inPageMiniImageView)
        addSubview(inPageMiniMessageLabel)
        addSubview(inPageMiniSizeCheckButton)
    }

    private func setConstraints() {
        inPageMiniImageView.translatesAutoresizingMaskIntoConstraints = false
        inPageMiniMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        inPageMiniSizeCheckButton.translatesAutoresizingMaskIntoConstraints = false

        let views = [
            "inPageMiniImageView": inPageMiniImageView,
            "messageLabel": inPageMiniMessageLabel,
            "sizeCheckButton": inPageMiniSizeCheckButton
        ]
        let metrics = [
            "horizontalMargin": defaultMargin,
            "verticalMargin": verticalMargin,
            "messageAndButtonMargin": messageAndButtonMargin
        ]

        // swiftlint:disable line_length
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-horizontalMargin-[inPageMiniImageView]-0-[messageLabel]-(>=messageAndButtonMargin)-[sizeCheckButton]-horizontalMargin-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        let inPageMiniImageViewVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=verticalMargin)-[inPageMiniImageView(18)]-(>=verticalMargin)-|",
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
        addConstraints(inPageMiniImageViewVerticalConstraints)
        addConstraints(messageLabelVerticalConstraints)
        addConstraints(sizeCheckButtonVerticalConstraints)
        addConstraint(inPageMiniImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor))
        addConstraint(inPageMiniSizeCheckButton.centerYAnchor.constraint(equalTo: self.centerYAnchor))
    }

    private func setStyle() {
        backgroundColor = getBackgroundColor()

        inPageMiniImageView.contentMode = .scaleAspectFit

        inPageMiniMessageLabel.numberOfLines = 0
        inPageMiniMessageLabel.textColor = UIColor.white
        inPageMiniMessageLabel.setContentHuggingPriority(.required, for: .horizontal)
        inPageMiniSizeCheckButton.backgroundColor = UIColor.white
        inPageMiniSizeCheckButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 6)
        inPageMiniSizeCheckButton.setTitle(Localization.shared.localize("check_size"), for: .normal)

        setupTextsStyle()

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

    private func getBackgroundColor() -> UIColor {
        if inPageMiniBackgroundColor != nil {
            return inPageMiniBackgroundColor!
        } else if style == .TEAL {
            return Colors.vsTealColor
        } else {
            return Colors.gray900Color
        }
    }

    private func setupTextsStyle(messageLabelIsBold: Bool = false) {
        let displayLanguage = Virtusize.params?.language
        switch displayLanguage {
        case .ENGLISH:
            inPageMiniMessageLabel.font = Font.proximaNova(size: 14, weight: messageLabelIsBold ? .bold : .regular)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.proximaNova(size: 12)
        case .JAPANESE:
            inPageMiniMessageLabel.font = Font.notoSansCJKJP(size: 12, weight: messageLabelIsBold ? .bold : .regular)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.notoSansCJKJP(size: 10)
        case .KOREAN:
            inPageMiniMessageLabel.font = Font.notoSansCJKKR(size: 12, weight: messageLabelIsBold ? .bold : .regular)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.notoSansCJKKR(size: 10)
        default:
            inPageMiniMessageLabel.font = Font.proximaNova(size: 14, weight: messageLabelIsBold ? .bold : .regular)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.proximaNova(size: 12)
        }
    }

    private func setLoadingScreen(loading: Bool) {
        backgroundColor = loading ? .white : getBackgroundColor()
        inPageMiniImageView.image = loading ? Assets.icon : nil
        inPageMiniMessageLabel.textColor = loading ? Colors.gray900Color : .white
        setupTextsStyle(messageLabelIsBold: loading)
        if loading {
            startLoadingAnimation(
                label: inPageMiniMessageLabel,
                text: Localization.shared.localize("inpage_loading_text")
            )
        } else {
            stopLoadingAnimation()
        }
        inPageMiniSizeCheckButton.isHidden = loading ? true: false
    }

	internal override func showErrorScreen() {
        backgroundColor = .white
        stopLoadingAnimation()
        inPageMiniImageView.image = Assets.errorHanger
        inPageMiniMessageLabel.textColor = Colors.gray700Color
        inPageMiniMessageLabel.text = Localization.shared.localize("inpage_error_short_text")
        inPageMiniSizeCheckButton.isHidden = true
        inPageMiniSizeCheckButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
        setupTextsStyle(messageLabelIsBold: false)
        isUserInteractionEnabled = false
    }
}
