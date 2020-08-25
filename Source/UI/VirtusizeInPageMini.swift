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
public class VirtusizeInPageMini: UIView, VirtusizeView, CAAnimationDelegate {

    public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
        didSet {
            setup()
        }
    }

    public var inPageMiniBackgroundColor: UIColor? {
        didSet {
            setStyle()
        }
    }

    public var presentingViewController: UIViewController?
    public var messageHandler: VirtusizeMessageHandler?

    private let horizontalEdgePadding: CGFloat = 8
    private let imageLabelPadding: CGFloat = 8
    private let verticalPadding: CGFloat = 5

    private let inPageMiniMessageLabel: UILabel = UILabel()
    private let inPageMiniSizeCheckButton: UIButton = UIButton()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isHidden = true
        setup()
    }

    public init() {
        super.init(frame: .zero)
        isHidden = true
        setup()
    }

    public func setupHorizontalMargin(view: UIView, margin: CGFloat) {
        view.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: margin
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: margin
            )
        )
    }

    private func setup() {
        addSubviews()
        setConstraints()
        setStyle()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openVirtusizeWebView))
        addGestureRecognizer(gestureRecognizer)
    }

    public func setupProductDataCheck() {
        guard let product = Virtusize.product else {
            return
        }
        self.setupInPageText(product: product, onCompletion: {
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
            "edgePadding": horizontalEdgePadding,
            "verticalPadding": verticalPadding,
            "imageLabelPadding": imageLabelPadding
        ]

        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-edgePadding-[messageLabel]-(>=imageLabelPadding)-[sizeCheckButton]-(edgePadding)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        let messageLabelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-verticalPadding-[messageLabel]-verticalPadding-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        let sizeCheckButtonVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=verticalPadding)-[sizeCheckButton]-(>=verticalPadding)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        addConstraints(horizontalConstraints)
        addConstraints(messageLabelVerticalConstraints)
        addConstraints(sizeCheckButtonVerticalConstraints)
        addConstraint(inPageMiniSizeCheckButton.centerYAnchor.constraint(equalTo: self.centerYAnchor))
    }

    private func setStyle() {
        if inPageMiniBackgroundColor != nil {
            backgroundColor = inPageMiniBackgroundColor
        } else if style == .TEAL {
            backgroundColor = Assets.vsTealColor
        } else {
            backgroundColor = Assets.gray900color
        }

        inPageMiniMessageLabel.numberOfLines = 0
        inPageMiniMessageLabel.textColor = UIColor.white
        inPageMiniMessageLabel.setContentHuggingPriority(.required, for: .horizontal)

        inPageMiniSizeCheckButton.isHidden = false
        inPageMiniSizeCheckButton.backgroundColor = UIColor.white
        inPageMiniSizeCheckButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 6)
        inPageMiniSizeCheckButton.setTitle(Localization.shared.localize("check_size"), for: .normal)
        let displayLanguage = Virtusize.params?.language
        switch displayLanguage {
        case .ENGLISH:
            inPageMiniMessageLabel.font = Font.proximaNovaRegular(size: 14)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.proximaNovaRegular(size: 12)
        case .JAPANESE:
            inPageMiniMessageLabel.font = Font.notoSansCJKJPRegular(size: 12)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.notoSansCJKJPRegular(size: 10)
        case .KOREAN:
            inPageMiniMessageLabel.font = Font.notoSansCJKKRRegular(size: 12)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.notoSansCJKKRRegular(size: 10)
        default:
            inPageMiniMessageLabel.font = Font.proximaNovaRegular(size: 14)
            inPageMiniSizeCheckButton.titleLabel?.font = Font.proximaNovaRegular(size: 12)
        }
        if displayLanguage == VirtusizeLanguage.JAPANESE || displayLanguage == VirtusizeLanguage.KOREAN {
            inPageMiniSizeCheckButton.layer.cornerRadius = 10
        } else {
            inPageMiniSizeCheckButton.layer.cornerRadius = 12
        }

        inPageMiniSizeCheckButton.setImage(
            Assets.rightArrow?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate),
            for: .normal
        )
        inPageMiniSizeCheckButton.semanticContentAttribute = .forceRightToLeft
        if inPageMiniBackgroundColor != nil {
            inPageMiniSizeCheckButton.setTitleColor(inPageMiniBackgroundColor, for: .normal)
            inPageMiniSizeCheckButton.imageView?.tintColor = inPageMiniBackgroundColor
        } else if style == .TEAL {
            inPageMiniSizeCheckButton.setTitleColor(Assets.vsTealColor, for: .normal)
            inPageMiniSizeCheckButton.imageView?.tintColor = Assets.vsTealColor
        } else {
            inPageMiniSizeCheckButton.setTitleColor(Assets.gray900color, for: .normal)
            inPageMiniSizeCheckButton.imageView?.tintColor = Assets.gray900color
        }
        inPageMiniSizeCheckButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    @objc private func openVirtusizeWebView() {
        clickOnVirtusizeView()
    }

    /// Sets up the InPage text by the product info
    ///
    /// - Parameters:
    ///   - product: `VirtusizeProduct`
    ///   - onCompletion: The callback for the completion of setting up the InPage text
    private func setupInPageText(product: VirtusizeProduct, onCompletion: (() -> Void)? = nil) {
        if let productId = product.productCheckData?.productDataId {
            Virtusize.getStoreProductInfo(productId: productId, onSuccess: { storeProduct in
                Virtusize.getI18nTexts(
                    onSuccess: { i18nLocalization in
                        self.inPageMiniMessageLabel.text =
                            storeProduct.getRecommendationText(i18nLocalization: i18nLocalization)
                        onCompletion?()
                }, onError: { error in
                    print(error.debugDescription)
                })
            }, onError: { error in
                print(error.debugDescription)
            })
        }
    }
}
