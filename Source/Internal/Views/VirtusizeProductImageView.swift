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

	override var isHidden: Bool {
		get {
			return super.isHidden
		}
		set(value) {
			super.isHidden = value
			if !value && productImageType == .USER {
				circleBorderLayer.isHidden = false
			} else {
				circleBorderLayer.isHidden = true
			}
		}
	}

	enum ProductImageType {
		case USER, STORE
	}

    private var imageSize: CGFloat = 40

    private var productImageView: UIImageView = UIImageView()

	private let circleBorderLayer = CAShapeLayer()

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

	var productImageType: ProductImageType = ProductImageType.STORE {
		didSet {
			setStyle()
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
		backgroundColor = UIColor.white
        addSubview(productImageView)

        setStyle()
    }

    private func setStyle() {
		frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
		layer.cornerRadius = imageSize / 2

		if productImageType == .STORE {
			layer.borderWidth = 0.5
			layer.borderColor = Colors.gray800Color.cgColor
		} else {
			circleBorderLayer.path = UIBezierPath(ovalIn: bounds).cgPath
			circleBorderLayer.lineWidth = 2.0
			circleBorderLayer.strokeColor = Colors.vsDarkTealColor.cgColor
			circleBorderLayer.lineDashPattern = [4, 3]
			circleBorderLayer.frame = bounds
			circleBorderLayer.fillColor = nil
			layer.borderColor = UIColor.white.cgColor
			layer.addSublayer(circleBorderLayer)
			layer.zPosition = 1
		}

        productImageView.center = center
        productImageView.frame = CGRect(x: 2, y: 2, width: imageSize - 4, height: imageSize - 4)
        productImageView.layer.cornerRadius = (imageSize - 4) / 2
        productImageView.layer.masksToBounds = true
		productImageView.contentMode = .scaleAspectFit
    }

    internal func setImage(product: VirtusizeInternalProduct, localImageUrl: URL?, completion: (() -> Void)? = nil) {
        if localImageUrl != nil {
            loadImageUrl(url: localImageUrl!, product: product, success: {
                completion?()
            }, failure: {
                self.setImage(product: product, localImageUrl: nil, completion: completion)
            })
            return
        }
        if let remoteImageUrl = getCloudinaryImageUrl(product.cloudinaryPublicId) {
            loadImageUrl(url: remoteImageUrl, product: product, success: {
                completion?()
            }, failure: {
                self.setProductTypeImage(
                    productType: product.productType,
                    style: product.storeProductMeta?.additionalInfo?.style
                )
                completion?()
            })
        } else {
            completion?()
            setProductTypeImage(
                productType: product.productType,
                style: product.storeProductMeta?.additionalInfo?.style
            )
        }
    }

    private func loadImageUrl(
        url: URL,
        product: VirtusizeInternalProduct,
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
            "https://res.cloudinary.com/virtusize/image/upload/w_36,h_36/q_auto,f_auto,dpr_auto/\(cloudinaryPublicId).jpg"
            )
    }

    private func setProductTypeImage(productType: Int, style: String?) {
        self.productImageView.image = Assets.getProductPlaceholderImage(
            productType: productType,
            style: style
        )?.withPadding(inset: 8)?.withRenderingMode(.alwaysTemplate)
		if productImageType == .STORE {
			self.productImageView.backgroundColor = Colors.gray200Color
			self.productImageView.tintColor = UIColor.black
		} else {
			self.productImageView.backgroundColor = UIColor.white
			self.productImageView.tintColor = Colors.vsTealColor
		}
    }
}
