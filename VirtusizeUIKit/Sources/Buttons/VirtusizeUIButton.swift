//
//  VirtusizeUIButton.swift
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

public class VirtusizeUIButton: VirtusizeUIBaseButton {
	struct Constants {
		static let imagePadding = CGFloat(4)
		static let imageSize = CGFloat(24)
	}

	public var size = VirtusizeUIButtonSize.large {
		didSet {
			setStyle()
		}
	}

	public override var isEnabled: Bool {
		didSet {
			setStyle()
		}
	}

	public override var backgroundColor: UIColor? {
		didSet {
			setStyle()
		}
	}

	public var leftImage: UIImage? {
		didSet {
			setAttributedTitle()
		}
	}

	public var rightImage: UIImage? {
		didSet {
			setAttributedTitle()
		}
	}

	private func setAttributedTitle() {
		var attributedTitle = NSMutableAttributedString()

		if var leftImage = leftImage {
			if style == .inverted {
				leftImage = leftImage.tintColor(.white) ?? leftImage
			}
			let leftAttachment = NSTextAttachment(data: nil, ofType: nil)
			let leftResizedImage = resizeImage(image: leftImage)
			leftAttachment.image = leftResizedImage
			leftAttachment.bounds = CGRect(
				x: 0,
				y: ((titleLabel?.font.capHeight ?? 0) - leftResizedImage.size.height) / 2,
				width: leftResizedImage.size.width,
				height: leftResizedImage.size.height
			)
			let attributedString = NSAttributedString(attachment: leftAttachment)
			let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)

			attributedTitle = mutableAttributedString
			attributedTitle.append(
				NSAttributedString(string: "\u{200B}", attributes: [NSAttributedString.Key.kern: Constants.imagePadding])
			)
		}

		if let title = currentTitle {
			attributedTitle.append(NSAttributedString(string: title))
		}

		if var rightImage = rightImage {
			if style == .inverted {
				rightImage = rightImage.tintColor(.white) ?? rightImage
			}
			attributedTitle.append(
				NSAttributedString(string: "\u{200B}", attributes: [NSAttributedString.Key.kern: Constants.imagePadding])
			)
			let rightAttachment = NSTextAttachment(data: nil, ofType: nil)
			let rightResizedImage = resizeImage(image: rightImage)
			rightAttachment.image = rightResizedImage
			rightAttachment.bounds = CGRect(
				x: 0,
				y: ((titleLabel?.font.capHeight ?? 0) - rightResizedImage.size.height) / 2,
				width: rightResizedImage.size.width,
				height: rightResizedImage.size.height
			)
			let attributedString = NSAttributedString(attachment: rightAttachment)
			let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
			attributedTitle.append(mutableAttributedString)
		}

		setAttributedTitle(attributedTitle, for: .normal)
	}

	private func resizeImage(image: UIImage) -> UIImage {
		let originalHeight = image.size.height
		let resizedImage = image.resize(
			to: CGSize(width: image.size.width * Constants.imageSize / originalHeight, height: Constants.imageSize)
		)
		return resizedImage
	}

	public init() {
		super.init(frame: .zero)
		setup()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	public override func layoutSubviews() {
		super.layoutSubviews()

		rippleView.frame = bounds
		rippleView.layer.mask = rippleMask
	}

	internal override func setStyle() {
		super.setStyle()

		setTitle("Default Button", for: .normal)
	}

	override internal func setButtonSize() {
		let typography = VirtusizeTypography()
		// swiftlint:disable switch_case_alignment
		switch size {
			case .small:
				titleLabel?.font = typography.xSmallBoldFont
				contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
			case .medium:
				titleLabel?.font = typography.smallBoldFont
				contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
			case .large:
				titleLabel?.font = typography.normalBoldFont
				contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
			case .xlarge:
				titleLabel?.font = typography.largeBoldFont
				contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
			case .xxlarge:
				titleLabel?.font = typography.xLargeBoldFont
				contentEdgeInsets = UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
		}
		layer.cornerRadius = intrinsicContentSize.height / 2
	}
}
