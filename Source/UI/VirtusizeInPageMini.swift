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

    public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE

    public let inPageMiniMessageLabel: UILabel = UILabel()
    public let inPageMiniSizeCheckButton: UIButton = UIButton()

    func setup() {
        addSubviews()
    }

    public func setupProductDataCheck() {
        guard let product = Virtusize.product,
            product.productCheckData != nil else {
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
