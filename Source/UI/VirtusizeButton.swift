//
//  VirtusizeButton.swift
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
public class VirtusizeButton: UIButton, VirtusizeView, CAAnimationDelegate {

    override public var isHighlighted: Bool {
        didSet {
            if style == .BLACK {
                backgroundColor = isHighlighted ? Assets.gray900PressedColor : Assets.gray900color
            } else if style == .TEAL {
                backgroundColor = isHighlighted ? Assets.vsTealPressedColor : Assets.vsTealColor
            }
        }
    }

    public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
        didSet {
           setup()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isHidden = true
    }

    public init() {
        super.init(frame: .zero)
        isHidden = true
        setup()
    }

    public func setupProductDataCheck() {
        guard let product = Virtusize.product else {
            return
        }
        if product.productCheckData?.validProduct ?? false {
            self.isHidden = false
        }
    }

    /// Set up the style of `VirtusizeView`
    private func setup() {
        if style == .NONE {
            setTitle(Localization.shared.localize("check_size"), for: .normal)
            setTitleColor(Assets.gray900color, for: .normal)
            setTitleColor(Assets.gray900PressedColor, for: .highlighted)
            return
        }

        if style == .BLACK {
            backgroundColor = Assets.gray900color
        } else if style == .TEAL {
            backgroundColor = Assets.vsTealColor
        }

        setTitle(Localization.shared.localize("check_size"), for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        tintColor = .white
        layer.cornerRadius = 20
        titleLabel?.font = .systemFont(ofSize: 12)

        contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

        setImage(Assets.icon?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        setImage(Assets.icon?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .highlighted)
    }
}
