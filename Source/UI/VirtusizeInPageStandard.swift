//
//  VirtusizeInPageStandard.swift
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

public class VirtusizeInPageStandard: UIView, VirtusizeView, CAAnimationDelegate {

    public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
        didSet {
            setup()
        }
    }

    public var inPageStandardButtonBackgroundColor: UIColor? {
        didSet {
            setStyle()
        }
    }

    public var presentingViewController: UIViewController?
    public var messageHandler: VirtusizeMessageHandler?

    private let inPageStandardView: UIView = UIView()
    private let productImageView: VirtusizeProductImageView = VirtusizeProductImageView(size: 40)
    private let messageStackView: UIStackView = UIStackView()
    private let topMessageLabel: UILabel = UILabel()
    private let bottomMessageLabel: UILabel = UILabel()
    private let checkSizeButton: UIButton = UIButton()
    private let virtusizeImageView: UIImageView = UIImageView()
    private let privacyPolicyLink: UILabel = UILabel()

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
        setHorizontalMargins(view: view, margin: margin)
    }

    private func setup() {
        addSubviews()
        setConstraints()
        setStyle()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openVirtusizeWebView))
        inPageStandardView.addGestureRecognizer(gestureRecognizer)
        checkSizeButton.addGestureRecognizer(gestureRecognizer)
    }

    private func addSubviews() {
        addSubview(inPageStandardView)
        addSubview(virtusizeImageView)
        addSubview(privacyPolicyLink)
        inPageStandardView.addSubview(productImageView)
        inPageStandardView.addSubview(messageStackView)
        messageStackView.addArrangedSubview(topMessageLabel)
        messageStackView.addArrangedSubview(bottomMessageLabel)
        inPageStandardView.addSubview(checkSizeButton)
    }

    private func setConstraints() {
        inPageStandardView.translatesAutoresizingMaskIntoConstraints = false
        virtusizeImageView.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyLink.translatesAutoresizingMaskIntoConstraints = false
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        messageStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        checkSizeButton.translatesAutoresizingMaskIntoConstraints = false

        let views = [
            "inPageStandardView": inPageStandardView,
            "virtusizeImageView": virtusizeImageView,
            "privacyPolicyLink": privacyPolicyLink,
            "productImageView": productImageView,
            "messageStackView": messageStackView,
            "topMessageLabel": topMessageLabel,
            "bottomMessageLabel": bottomMessageLabel,
            "checkSizeButton": checkSizeButton
        ]

        let inPageStandardViewHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[inPageStandardView]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let inPageStandardViewVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[inPageStandardView]-10-[virtusizeImageView]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let footerHorizontalConstraints = NSLayoutConstraint.constraints(
                   withVisualFormat: "H:|-0-[virtusizeImageView(>=10)]-(>=0)-[privacyPolicyLink(>=15)]-0-|",
                   options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                   metrics: nil,
                   views: views
        )

        privacyPolicyLink.centerYAnchor.constraint(
            equalTo: virtusizeImageView.centerYAnchor,
            constant: 0
        ).isActive = true
        virtusizeImageView.centerYAnchor.constraint(
            equalTo: privacyPolicyLink.centerYAnchor,
            constant: 0
        ).isActive = true

        let inPageStandardViewsHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-8-[productImageView(==40)]-4-[messageStackView]-(>=8)-[checkSizeButton]-8-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let productImageViewVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=14)-[productImageView(==40)]-(>=14)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let messageStackViewVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=14.5)-[messageStackView]-(>=14.5)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let checkSizeButtonVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=20)-[checkSizeButton]-(>=20)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        addConstraints(inPageStandardViewHorizontalConstraints)
        addConstraints(inPageStandardViewVerticalConstraints)
        addConstraints(footerHorizontalConstraints)
        addConstraints(inPageStandardViewsHorizontalConstraints)
        addConstraints(productImageViewVerticalConstraints)
        addConstraints(messageStackViewVerticalConstraints)
        addConstraints(checkSizeButtonVerticalConstraints)

        addConstraint(productImageView.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(messageStackView.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(checkSizeButton.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
    }

    private func setStyle() {
        inPageStandardView.backgroundColor = .white
        inPageStandardView.layer.masksToBounds = false
        inPageStandardView.layer.shadowColor = Assets.inPageShadowColor.cgColor
        inPageStandardView.layer.shadowOpacity = 1
        inPageStandardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        inPageStandardView.layer.shadowRadius = 14

        virtusizeImageView.image = Assets.vsSignature

        privacyPolicyLink.text = Localization.shared.localize("privacy_policy")
        privacyPolicyLink.setContentHuggingPriority(.required, for: .vertical)

        productImageView.image = #imageLiteral(resourceName: "logo-vs-horizontal-color")

        messageStackView.axis = .vertical
        messageStackView.distribution = .equalSpacing
        messageStackView.spacing = 2

        topMessageLabel.numberOfLines = 0
        topMessageLabel.textColor = Assets.gray900color
        bottomMessageLabel.numberOfLines = 0
        bottomMessageLabel.textColor = Assets.gray900color

        if inPageStandardButtonBackgroundColor != nil {
            checkSizeButton.backgroundColor = inPageStandardButtonBackgroundColor
        } else if style == .TEAL {
            checkSizeButton.backgroundColor = Assets.vsTealColor
        } else {
            checkSizeButton.backgroundColor = Assets.gray900color
        }
        checkSizeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 6)
        checkSizeButton.setTitle(Localization.shared.localize("check_size"), for: .normal)
        checkSizeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        checkSizeButton.layer.cornerRadius = checkSizeButton.intrinsicContentSize.height / 2
        checkSizeButton.setImage(
            Assets.rightArrow?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate),
            for: .normal
        )
        checkSizeButton.semanticContentAttribute = .forceRightToLeft
        checkSizeButton.imageView?.tintColor = UIColor.white

        let displayLanguage = Virtusize.params?.language
        switch displayLanguage {
        case .ENGLISH:
            topMessageLabel.font = Font.proximaNova(size: 14)
            bottomMessageLabel.font = Font.proximaNova(size: 18, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.proximaNova(size: 14)
            privacyPolicyLink.font = Font.proximaNova(size: 12)
        case .JAPANESE:
            topMessageLabel.font = Font.notoSansCJKJP(size: 12)
            bottomMessageLabel.font = Font.notoSansCJKJP(size: 16, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.notoSansCJKJP(size: 12)
            privacyPolicyLink.font = Font.notoSansCJKJP(size: 10)
        case .KOREAN:
            topMessageLabel.font = Font.notoSansCJKKR(size: 12)
            bottomMessageLabel.font = Font.notoSansCJKKR(size: 16, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.notoSansCJKKR(size: 12)
            privacyPolicyLink.font = Font.notoSansCJKKR(size: 10)
        default:
            break
        }
    }

    @objc private func openVirtusizeWebView() {
        clickOnVirtusizeView()
    }

    public func setupProductDataCheck() {
        guard let product = Virtusize.product else {
            return
        }
        setupInPageText(product: product, onCompletion: { storeProduct, i18nLocalization in
            let recommendationText = storeProduct.getRecommendationText(i18nLocalization: i18nLocalization)
            let breakTag = VirtusizeI18nLocalization.TrimType.MULTIPLELINES.rawValue
            let recommendationTextArray = recommendationText.components(separatedBy: breakTag)
            if recommendationTextArray.count == 2 {
                self.topMessageLabel.text = recommendationTextArray[0]
                self.bottomMessageLabel.text = recommendationTextArray[1]
            } else {
                self.topMessageLabel.isHidden = true
                self.bottomMessageLabel.text = recommendationText
            }
            self.isHidden = false
        })
    }
}
