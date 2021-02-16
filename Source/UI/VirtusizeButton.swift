//
//  VirtusizeButton.swift
//
//  Copyright (c) 2018-present Virtusize KK
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

/// This class is the custom Virtusize Button that is added in the client's layout file.
public class VirtusizeButton: UIButton, CAAnimationDelegate {

	override public var isHighlighted: Bool {
		didSet {
			if style == .BLACK {
				backgroundColor = isHighlighted ? .vsGray900PressedColor : .vsGray900Color
			} else if style == .TEAL {
				backgroundColor = isHighlighted ? .vsTealPressedColor : .vsTealColor
			}
		}
	}

	public var style: VirtusizeViewStyle?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
		isHidden = true
    }

	public init() {
		super.init(frame: .zero)
		isHidden = true
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
                self?.isHidden = false
            }
        }
        get {
            return Virtusize.product
        }
    }

	/// Applies the default style of `VirtusizeButton`
	public func applyDefaultStyle(_ virtusizeStyle: VirtusizeViewStyle = .BLACK) {
		style = virtusizeStyle

		setTitle(Localization.shared.localize("Check size"), for: .normal)

		if virtusizeStyle == .BLACK {
			backgroundColor = .vsGray900Color
		} else {
			backgroundColor = .vsTealColor
		}

		setTitleColor(.white, for: .normal)
		setTitleColor(.white, for: .highlighted)

		tintColor = .white
		layer.cornerRadius = 20
		titleLabel?.font = .systemFont(ofSize: 12)

		contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

		setImage(VirtusizeAssets.icon?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
		setImage(VirtusizeAssets.icon?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .highlighted)
	}
}
