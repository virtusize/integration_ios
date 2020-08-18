//
//  VirtusizeView.swift
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

import UIKit

/// This class is the custom Virtusize View that is added in the client's layout file.
public class VirtusizeView: UIButton, CAAnimationDelegate {

    var virtusizeViewType = VirtusizeViewType.BUTTON

    @IBInspectable var viewType: String {
        set {
            self.virtusizeViewType = VirtusizeViewType(rawValue: newValue) ?? VirtusizeViewType.BUTTON
            setup()
        }
        get {
            return virtusizeViewType.rawValue
        }
    }

    /// `VirtusizeProduct` that is being set to this button
    public var storeProduct: VirtusizeProduct? {
        set {
            guard let product = newValue else {
                isHidden = true
                return
            }
            Virtusize.productCheck(product: product) { [weak self] product in
                guard let product = product else {
                    self?.isHidden = true
                    return
                }
                Virtusize.product = product
                if self?.virtusizeViewType == VirtusizeViewType.INPAGE {
                    self?.setupInPageText(product: product, onCompletion: {
                        self?.isHidden = false
                    })
                } else {
                    self?.isHidden = false
                }
            }
        }
        get {
            return Virtusize.product
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    init(virtusizeViewType: VirtusizeViewType) {
        super.init(frame: .zero)
        self.virtusizeViewType = virtusizeViewType
    }

    private func setup() {
        if self.virtusizeViewType == VirtusizeViewType.INPAGE {
            setTitle("", for: .normal)
        }
    }

    /// Applies the default style of `VirtusizeView`
    public func applyDefaultButtonStyle() {
        guard self.virtusizeViewType == VirtusizeViewType.BUTTON else {
            return
        }
        tintColor = .black

        setTitle(Localization.shared.localize("check_size"), for: .normal)

        backgroundColor = UIColor(white: 58.0 / 255.0, alpha: 1.0)
        tintColor = .white
        layer.cornerRadius = 20

        contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        self.setImage(Assets.icon, for: .normal)
    }

    private func setupInPageText(product: VirtusizeProduct, onCompletion: (() -> Void)? = nil) {
        if let productId = product.productCheckData?.productDataId {
            Virtusize.getStoreProductInfo(productId: productId, onSuccess: { storeProduct in
                Virtusize.getI18nTexts(
                    onSuccess: { i18nLocalization in
                        self.setTitle(
                            storeProduct.getRecommendationText(i18nLocalization: i18nLocalization),
                            for: .normal
                        )
                }, onError: { error in
                    print(error.debugDescription)
                })
                onCompletion?()
            }, onError: { error in
                print(error.debugDescription)
            })
        }
    }
}
