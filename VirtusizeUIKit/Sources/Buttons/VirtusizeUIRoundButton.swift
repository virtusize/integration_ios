//
//  VirtusizeUIRoundButton.swift
//  VirtusizeUIKit
//
//  Copyright (c) 2021 Virtusize KK
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
import Foundation

public class VirtusizeUIRoundButton: VirtusizeUIBaseButton {
	struct Constant {
		static let size = CGFloat(40)
		static let padding = CGFloat(8)
		static let maxImageSize = CGFloat(size - 2 * padding)
	}

	public init() {
		super.init(frame: .zero)
		setup()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	internal override func setup() {
		super.setup()
		addImage(VirtusizeAssets.searchProduct)
	}

	private func addImage(_ image: UIImage?) {
		guard let image = image else {
			return
		}
		var resizeImage = image
		if image.size.width > image.size.height {
			let originWidth = image.size.width
			resizeImage = image.resize(
				to: CGSize(width: Constant.maxImageSize, height: image.size.height * Constant.maxImageSize / originWidth)
			)
		} else {
			let originHeight = image.size.height
			resizeImage = image.resize(
				to: CGSize(width: image.size.width * Constant.maxImageSize / originHeight, height: Constant.maxImageSize)
			)
		}
		setImage(resizeImage.withAlpha(0), for: .normal)
		let imageView = UIImageView(image: image)
		addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	override internal func setButtonSize() {
		let typography = VirtusizeTypography()
		titleLabel?.font = typography.normalBoldFont
		contentEdgeInsets = UIEdgeInsets(
			top: Constant.padding,
			left: Constant.padding,
			bottom: Constant.padding,
			right: Constant.padding
		)
		layer.cornerRadius = Constant.size / 2
	}
}
