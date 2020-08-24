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

public class VirtusizeInPageMini: UIView, VirtusizeView, CAAnimationDelegate {

    public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
        didSet {
            setup()
        }
    }

    public var presentingViewController: UIViewController?
    public var messageHandler: VirtusizeMessageHandler?

    public let horizontalEdgePadding: CGFloat = 16
    public let imageLabelPadding: CGFloat = 8
    public let verticalPadding: CGFloat = 10

    public let inPageMiniMessageLabel: UILabel = UILabel()
    public let inPageMiniSizeCheckButton: UIButton = UIButton()

    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         isHidden = true
     }

     public init() {
         super.init(frame: .zero)
         isHidden = true
         setup()
     }

    func setup() {
        addSubviews()
        setContent()
        setConstraints()

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

    private func setContent() {
        clipsToBounds = true
    }

    private func setConstraints() {

        inPageMiniMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        inPageMiniSizeCheckButton.translatesAutoresizingMaskIntoConstraints = false

        let views = ["messageLabel": inPageMiniMessageLabel, "sizeCheckButton": inPageMiniSizeCheckButton]
        let metrics = ["edgePadding": horizontalEdgePadding, "verticalPadding": verticalPadding, "imageLabelPadding": imageLabelPadding]

        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-edgePadding-[messageLabel]-imageLabelPadding-[sizeCheckButton]-(edgePadding)-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-verticalPadding-[messageLabel]-verticalPadding-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: metrics,
            views: views
        )

        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }

    @objc func openVirtusizeWebView() {
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
