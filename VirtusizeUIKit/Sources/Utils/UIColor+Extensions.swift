//
//  UIColor+Extensions.swift
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

extension UIColor {

	/// Color brightness is determined by the following formula:
	/// ((Red value X 299) + (Green value X 587) + (Blue value X 114)) / 1000
	var isBright: Bool {
		let brightness = Float(((rgba.red * 299) + (rgba.green * 587) + (rgba.blue * 114)) / 1000)
		let threshold = Float(0.5)
		return brightness > threshold
	}

	func lighter(by percentage: CGFloat) -> UIColor? {
		return self.adjustLightness(by: abs(percentage) )
	}

	func darker(by percentage: CGFloat) -> UIColor? {
		return self.adjustLightness(by: -1 * abs(percentage) )
	}

	private typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
	private var rgba: RGBA {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return (red, green, blue, alpha)
	}

	private func adjustLightness(by percentage: CGFloat) -> UIColor {
		return UIColor(
			red: min(rgba.red + percentage/100, 1.0),
			green: min(rgba.green + percentage/100, 1.0),
			blue: min(rgba.blue + percentage/100, 1.0),
			alpha: rgba.alpha
		)
	}
}
