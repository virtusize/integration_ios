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

import UIKit

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

	init() {
		super.init(frame: .zero)
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
			layer.borderColor = UIColor.vsGray800Color.cgColor
		} else {
			circleBorderLayer.path = UIBezierPath(ovalIn: bounds).cgPath
			circleBorderLayer.lineWidth = 1.0
			circleBorderLayer.strokeColor = UIColor.vsDarkTealColor.cgColor
			circleBorderLayer.lineDashPattern = [4, 3]
			circleBorderLayer.frame = bounds
			circleBorderLayer.fillColor = nil
			circleBorderLayer.lineJoin = .round
			layer.borderColor = UIColor.clear.cgColor
			layer.addSublayer(circleBorderLayer)
			layer.zPosition = 1
		}

		productImageView.center = center
        productImageView.frame = CGRect(x: 2, y: 2, width: VirtusizeProductImageView.circleImageSize, height: VirtusizeProductImageView.circleImageSize)
        productImageView.layer.cornerRadius = VirtusizeProductImageView.circleImageSize / 2
		productImageView.layer.masksToBounds = true
		productImageView.contentMode = .scaleAspectFill
	}

	func setProductTypeImage(image: UIImage?) {
		if productImageType == .STORE {
			self.productImageView.backgroundColor = .vsGray200Color
			self.productImageView.tintColor = UIColor.black
		} else {
			self.productImageView.backgroundColor = UIColor.white
			self.productImageView.tintColor = .vsTealColor
		}
		productImageView.contentMode = .scaleAspectFit
	}
}

extension VirtusizeProductImageView {
    static let circleImageSize: CGFloat = 36
}
