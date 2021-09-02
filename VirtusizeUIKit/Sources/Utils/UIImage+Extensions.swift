//
//  UIImage+Extensions.swift
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

public extension UIImage {

	/// Creates a `UIImage` object in the VirtusizeUIKit framework bundle.
	///
	/// - Parameter name: The image name.
	convenience init?(for aClass: AnyClass, bundleNamed name: String) {
		self.init(
			named: name,
			in: VirtusizeUIKitBundleLoader.resourceBundle,
			compatibleWith: nil
		)
	}

	/// Adds the padding to a `UIImage`
	///
	/// - Parameter inset: the padding in CGFloat
	func withPadding(inset: CGFloat) -> UIImage? {
		return withInsets(insets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
	}

	private func withInsets(insets: UIEdgeInsets) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(
			CGSize(width: self.size.width + insets.left + insets.right,
				   height: self.size.height + insets.top + insets.bottom), false, self.scale)
		let origin = CGPoint(x: insets.left, y: insets.top)
		self.draw(at: origin)
		guard let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext() else {
			return nil
		}
		UIGraphicsEndImageContext()
		return imageWithInsets
	}

	func resize(to newSize: CGSize) -> UIImage {
		let image = UIGraphicsImageRenderer(size: newSize).image { (_) in
			draw(in: CGRect(origin: .zero, size: newSize))
		}
		return image.withRenderingMode(renderingMode)
	}

	func withAlpha(_ alpha: CGFloat) -> UIImage {
		return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { (_) in
			draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: alpha)
		}
	}
}
