//
//  VirtusizeButton.swift
//
//  Copyright (c) 2018 Virtusize AB
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

public class VirtusizeButton: UIButton {
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

    private var product: VirtusizeProduct?

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
                self?.product = product
                self?.isHidden = false
            }
        }
        get {
            return product
        }
    }

	public func applyDefaultStyle() {
		tintColor = .black

		setTitle(NSLocalizedString("Check the fit", comment: "Check the fit button title"), for: .normal)

		backgroundColor = UIColor(white: 58.0 / 255.0, alpha: 1.0)
		tintColor = .white

		contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.setImage(Assets.icon, for: .normal)
	}
}
