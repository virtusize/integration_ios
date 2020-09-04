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

import WebKit

/// TODO: Comment
public protocol VirtusizeView {
    var style: VirtusizeViewStyle { get }
    var presentingViewController: UIViewController? { get set }
    var messageHandler: VirtusizeMessageHandler? { get set }

    func setupProductDataCheck()
}

extension VirtusizeView {
    internal func clickOnVirtusizeView() {
        if let virtusize = VirtusizeViewController(handler: messageHandler, processPool: Virtusize.processPool) {
            presentingViewController?.present(virtusize, animated: true, completion: nil)
        }
    }

    /// Sets up the InPage text by the product info
    ///
    /// - Parameters:
    ///   - product: `VirtusizeProduct`
    ///   - onCompletion: The callback to pass `VirtusizeStoreProduct` and  `VirtusizeI18nLocalization`
    ///   for setting up the InPage text
    internal func setupInPageText(
        product: VirtusizeProduct,
        onCompletion: ((VirtusizeStoreProduct, VirtusizeI18nLocalization) -> Void)? = nil
    ) {
        if let productId = product.productCheckData?.productDataId {
            Virtusize.getStoreProductInfo(productId: productId, onSuccess: { storeProduct in
                Virtusize.getI18nTexts(
                    trimType: (self is VirtusizeInPageStandard) ?
                        VirtusizeI18nLocalization.TrimType.MULTIPLELINES :
                        VirtusizeI18nLocalization.TrimType.ONELINE,
                    onSuccess: { i18nLocalization in
                        onCompletion?(storeProduct, i18nLocalization)
                }, onError: { error in
                    print(error.debugDescription)
                })
            }, onError: { error in
                print(error.debugDescription)
            })
        }
    }
}
