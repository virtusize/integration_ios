//
//  VirtusizeProductImageView.swift
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

/// The custom view for setting up the store product image view from a URL
/// or replacing it with a product type placeholder image when the image URL is not available
internal class VirtusizeProductImageView: UIView {

    private var imageSize: CGFloat = 40

    private var productImageView: UIImageView = UIImageView()

    var image: UIImage? {
        set {
            if productImageView.image != newValue {
                productImageView.image = newValue
                setStyle()
            }
        }
        get {
            return productImageView.image
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    init(size: CGFloat) {
        super.init(frame: .zero)
        imageSize = size
        setup()
    }

    private func setup() {
        addSubview(productImageView)

        frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        layer.cornerRadius = imageSize / 2
        layer.borderWidth = 0.5
        layer.borderColor = Colors.gray800Color.cgColor

        setStyle()
    }

    private func setStyle() {
        productImageView.center = center
        productImageView.frame = CGRect(x: 2, y: 2, width: imageSize - 4, height: imageSize - 4)
        productImageView.layer.cornerRadius = (imageSize - 4) / 2
        productImageView.layer.masksToBounds = true
        productImageView.contentMode = .scaleAspectFill
    }

    internal func setImage(storeProduct: VirtusizeStoreProduct, localImageUrl: URL?, completion: (() -> Void)? = nil) {
        if localImageUrl != nil {
            loadImageUrl(url: localImageUrl!, storeProduct: storeProduct, success: {
                completion?()
            }, failure: {
                self.setImage(storeProduct: storeProduct, localImageUrl: nil, completion: completion)
            })
            return
        }
        if let remoteImageUrl = getCloudinaryImageUrl(storeProduct.cloudinaryPublicId) {
            loadImageUrl(url: remoteImageUrl, storeProduct: storeProduct, success: {
                completion?()
            }, failure: {
                self.setProductTypeImage(
                    productType: storeProduct.productType,
                    style: storeProduct.storeProductMeta?.additionalInfo?.style
                )
                completion?()
            })
        } else {
            completion?()
            setProductTypeImage(
                productType: storeProduct.productType,
                style: storeProduct.storeProductMeta?.additionalInfo?.style
            )
        }
    }

    private func loadImageUrl(
        url: URL,
        storeProduct: VirtusizeStoreProduct,
        success: (() -> Void)? = nil,
        failure: (() -> Void)? = nil
    ) {
        productImageView.load(url: url, success: { image in
            self.image = image.withPadding(inset: 4)
            success?()
        }, failure: {
            failure?()
        })
    }

    private func getCloudinaryImageUrl(_ cloudinaryPublicId: String?) -> URL? {
        guard let cloudinaryPublicId = cloudinaryPublicId else {
            return nil
        }
        return URL(string:
            "https://res.cloudinary.com/virtusize/image/upload/t_product-large-retina-v1/\(cloudinaryPublicId).jpg"
            )
    }

    private func setProductTypeImage(productType: Int, style: String?) {
        self.productImageView.image = Assets.getProductPlaceholderImage(
            productType: productType,
            style: style
        )?.withPadding(inset: 6)
        self.productImageView.contentMode = .scaleAspectFit
        self.productImageView.backgroundColor = Colors.gray200Color
    }

    internal func showCircleBorder() {
        layer.cornerRadius = imageSize / 2
        layer.borderWidth = 0.5
        productImageView.layer.cornerRadius = (imageSize - 4) / 2
    }

    internal func hideCircleBorder() {
        layer.cornerRadius = 0
        layer.borderWidth = 0
        productImageView.layer.cornerRadius = 0
    }
}
