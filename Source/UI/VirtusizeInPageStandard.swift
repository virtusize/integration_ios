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

// swiftlint:disable type_body_length
public class VirtusizeInPageStandard: VirtusizeInPageView {

    public var inPageStandardButtonBackgroundColor: UIColor? {
        didSet {
            setStyle()
        }
    }

    private let inPageStandardView: UIView = UIView()
    private let productImageView: VirtusizeProductImageView = VirtusizeProductImageView(size: 40)
    private let messageStackView: UIStackView = UIStackView()
    private let topMessageLabel: UILabel = UILabel()
    private let bottomMessageLabel: UILabel = UILabel()
    private let checkSizeButton: UIButton = UIButton()
    private let vsSignatureImageView: UIImageView = UIImageView()
    private let privacyPolicyLink: UILabel = UILabel()
    private let errorImageView: UIImageView = UIImageView()
    private let errorText: UILabel = UILabel()

    private var messageLineSpacing: CGFloat = 6

    public func setupHorizontalMargin(view: UIView, margin: CGFloat) {
        setHorizontalMargins(view: view, margin: margin)
    }

    internal override func setup() {
        addSubviews()
        setConstraints()
        setStyle()

        inPageStandardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openVirtusizeWebView))
        )
        
        checkSizeButton.addTarget(self, action: #selector(openVirtusizeWebView), for: .touchUpInside)

        privacyPolicyLink.isUserInteractionEnabled = true
        privacyPolicyLink.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(openPrivacyPolicyLink))
        )
    }

    private func addSubviews() {
        addSubview(inPageStandardView)
        addSubview(vsSignatureImageView)
        addSubview(privacyPolicyLink)
        inPageStandardView.addSubview(productImageView)
        inPageStandardView.addSubview(messageStackView)
        messageStackView.addArrangedSubview(topMessageLabel)
        messageStackView.addArrangedSubview(bottomMessageLabel)
        inPageStandardView.addSubview(checkSizeButton)
        inPageStandardView.addSubview(errorImageView)
        inPageStandardView.addSubview(errorText)
    }

    // swiftlint:disable function_body_length
    private func setConstraints() {
        inPageStandardView.translatesAutoresizingMaskIntoConstraints = false
        vsSignatureImageView.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyLink.translatesAutoresizingMaskIntoConstraints = false
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        messageStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        checkSizeButton.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorText.translatesAutoresizingMaskIntoConstraints = false

        let views = [
            "inPageStandardView": inPageStandardView,
            "virtusizeImageView": vsSignatureImageView,
            "privacyPolicyLink": privacyPolicyLink,
            "productImageView": productImageView,
            "messageStackView": messageStackView,
            "topMessageLabel": topMessageLabel,
            "bottomMessageLabel": bottomMessageLabel,
            "checkSizeButton": checkSizeButton,
            "errorImageView": errorImageView,
            "errorText": errorText
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

        let errorScreenVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-8-[errorImageView(40)]-8-[errorText]-8-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let errorImageViewHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(>=8)-[errorImageView(40)]-(>=8)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        let errorTextHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(>=8)-[errorText]-(>=8)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: views
        )

        privacyPolicyLink.centerYAnchor.constraint(
            equalTo: vsSignatureImageView.centerYAnchor,
            constant: 0
        ).isActive = true
        vsSignatureImageView.centerYAnchor.constraint(
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
        addConstraints(errorScreenVerticalConstraints)
        addConstraints(errorImageViewHorizontalConstraints)
        addConstraints(errorTextHorizontalConstraints)

        addConstraint(productImageView.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(messageStackView.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(checkSizeButton.centerYAnchor.constraint(equalTo: inPageStandardView.centerYAnchor))
        addConstraint(errorImageView.centerXAnchor.constraint(equalTo: inPageStandardView.centerXAnchor))
        addConstraint(errorText.centerXAnchor.constraint(equalTo: inPageStandardView.centerXAnchor))
    }

    // swiftlint:disable function_body_length
    private func setStyle() {
        inPageStandardView.backgroundColor = .white
        inPageStandardView.layer.masksToBounds = false
        inPageStandardView.layer.shadowColor = Colors.inPageShadowColor.cgColor
        inPageStandardView.layer.shadowOpacity = 1
        inPageStandardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        inPageStandardView.layer.shadowRadius = 14

        vsSignatureImageView.image = Assets.vsSignature

        privacyPolicyLink.text = Localization.shared.localize("privacy_policy")
        privacyPolicyLink.textColor = Colors.gray900Color
        privacyPolicyLink.setContentHuggingPriority(.required, for: .vertical)

        messageStackView.axis = .vertical
        messageStackView.distribution = .equalSpacing

        topMessageLabel.numberOfLines = 0
        topMessageLabel.textColor = Colors.gray900Color
        bottomMessageLabel.numberOfLines = 0
        bottomMessageLabel.textColor = Colors.gray900Color

        if inPageStandardButtonBackgroundColor != nil {
            checkSizeButton.backgroundColor = inPageStandardButtonBackgroundColor
        } else if style == .TEAL {
            checkSizeButton.backgroundColor = Colors.vsTealColor
        } else {
            checkSizeButton.backgroundColor = Colors.gray900Color
        }
        checkSizeButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 8, bottom: 6, right: 6)
        checkSizeButton.setTitle(Localization.shared.localize("check_size"), for: .normal)
        checkSizeButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let rightArrowImageTemplate = Assets.rightArrow?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        checkSizeButton.setImage(rightArrowImageTemplate, for: .normal)
        checkSizeButton.setImage(rightArrowImageTemplate, for: .highlighted)

        checkSizeButton.semanticContentAttribute = .forceRightToLeft
        checkSizeButton.imageView?.tintColor = UIColor.white

        errorImageView.image = Assets.errorHanger
        errorImageView.contentMode = .scaleAspectFit
        errorImageView.isHidden = true

        errorText.numberOfLines = 0
        errorText.textColor = Colors.gray700Color
        errorText.isHidden = true

        let displayLanguage = Virtusize.params?.language
        switch displayLanguage {
        case .ENGLISH:
            topMessageLabel.font = Font.proximaNova(size: 14)
            bottomMessageLabel.font = Font.proximaNova(size: 18, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.proximaNova(size: 14)
            privacyPolicyLink.font = Font.proximaNova(size: 12)
            errorText.font = Font.proximaNova(size: 12)
            messageLineSpacing = 2
        case .JAPANESE:
            topMessageLabel.font = Font.notoSansCJKJP(size: 12)
            bottomMessageLabel.font = Font.notoSansCJKJP(size: 16, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.notoSansCJKJP(size: 12)
            privacyPolicyLink.font = Font.notoSansCJKJP(size: 10)
            errorText.font = Font.notoSansCJKJP(size: 10)
            messageLineSpacing = 6
        case .KOREAN:
            topMessageLabel.font = Font.notoSansCJKKR(size: 12)
            bottomMessageLabel.font = Font.notoSansCJKKR(size: 16, weight: .bold)
            checkSizeButton.titleLabel?.font = Font.notoSansCJKKR(size: 12)
            privacyPolicyLink.font = Font.notoSansCJKKR(size: 10)
            errorText.font = Font.notoSansCJKKR(size: 10)
            messageLineSpacing = 6
        default:
            break
        }
        checkSizeButton.layer.cornerRadius = checkSizeButton.intrinsicContentSize.height / 2
        messageStackView.spacing = messageLineSpacing
    }

    @objc private func openPrivacyPolicyLink() {
        if let sharedApplication = UIApplication.safeShared,
            let url = URL(string: Localization.shared.localize("privacy_policy_link")) {
            sharedApplication.safeOpenURL(url)
        }
    }

    public override func setupProductDataCheck() {
        guard let product = Virtusize.product else {
            return
        }
        self.isHidden = false
        setLoadingScreen(loading: true)
        setupInPageText(product: product, onCompletion: { storeProduct, i18nLocalization in
            self.productImageView.setImage(storeProduct: storeProduct, localImageUrl: Virtusize.product?.imageURL) {
                self.setLoadingScreen(loading: false)
                let recommendationText = storeProduct.getRecommendationText(i18nLocalization: i18nLocalization)
                let breakTag = VirtusizeI18nLocalization.TrimType.MULTIPLELINES.rawValue
                let recommendationTextArray = recommendationText.components(separatedBy: breakTag)
                if recommendationTextArray.count == 2 {
                    self.topMessageLabel.attributedText = NSAttributedString(
                        string: recommendationTextArray[0]
                    ).lineSpacing(self.messageLineSpacing)
                    self.bottomMessageLabel.attributedText = NSAttributedString(
                        string: recommendationTextArray[1]
                    ).lineSpacing(self.messageLineSpacing)
                } else {
                    self.topMessageLabel.isHidden = true
                    self.bottomMessageLabel.attributedText = NSAttributedString(
                        string: recommendationText
                    ).lineSpacing(self.messageLineSpacing)
                }
            }
        }, failure: {
           self.showErrorScreen()
        })
    }

    private func setLoadingScreen(loading: Bool) {
        vsSignatureImageView.isHidden = loading ? true : false
        privacyPolicyLink.isHidden = loading ? true : false
        topMessageLabel.isHidden = loading ? true : false
        if loading {
            productImageView.image = Assets.icon
            productImageView.hideCircleBorder()
            startLoadingAnimation(
                label: bottomMessageLabel,
                text: Localization.shared.localize("inpage_standard_loading_text")
            )
        } else {
            productImageView.showCircleBorder()
            stopLoadingAnimation()
        }
    }

    private func showErrorScreen() {
        inPageStandardView.layer.shadowOpacity = 0
        inPageStandardView.isUserInteractionEnabled = false
        productImageView.isHidden = true
        bottomMessageLabel.isHidden = true
        checkSizeButton.isHidden = true
        errorImageView.isHidden = false
        errorText.isHidden = false
        errorText.attributedText = NSAttributedString(
            string: Localization.shared.localize("inpage_error_long_text")
        ).lineSpacing(self.messageLineSpacing)
        errorText.textAlignment = .center
    }
}
