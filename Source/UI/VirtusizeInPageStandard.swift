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
    private let productImageView: UIImageView = UIImageView()
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
                   withVisualFormat: "H:|-0-[inPageStandardView]|",
                   options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                   metrics: nil,
                   views: views
        )

        privacyPolicyLink.trailingAnchor.constraint(equalTo: inPageStandardView.trailingAnchor, constant: 0).isActive = true
        virtusizeImageView.centerYAnchor.constraint(equalTo: privacyPolicyLink.centerYAnchor, constant: 0).isActive = true

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
        virtusizeImageView.image = Assets.vsSignature

        privacyPolicyLink.text = "Privacy Policy"

        productImageView.image = #imageLiteral(resourceName: "logo-vs-horizontal-color")
        productImageView.contentMode = .scaleAspectFit

        messageStackView.axis = .vertical
        messageStackView.distribution = .equalSpacing
        messageStackView.spacing = 2

        topMessageLabel.text = "Top text"

        bottomMessageLabel.text = "Bottom text Bottom text"
        bottomMessageLabel.numberOfLines = 0
        bottomMessageLabel.isHidden = true

        checkSizeButton.backgroundColor = Assets.vsTealColor
        checkSizeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 6)
        checkSizeButton.setTitle(Localization.shared.localize("check_size"), for: .normal)
        checkSizeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        checkSizeButton.layer.cornerRadius = checkSizeButton.intrinsicContentSize.height / 2
    }

    @objc private func openVirtusizeWebView() {
        clickOnVirtusizeView()
    }

    public func setupProductDataCheck() {
        guard let product = Virtusize.product else {
            return
        }
        setupInPageText(product: product, onCompletion: { storeProduct, i18nLocalization in
            self.isHidden = false
        })
    }
}
