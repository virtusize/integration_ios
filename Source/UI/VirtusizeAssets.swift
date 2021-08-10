//
//  VirtusizeAssets.swift
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

/// This class wraps the assets including colors and images used in the Virtusize SDK
final public class VirtusizeAssets {
	public static let bundle = Bundle(for: VirtusizeAssets.self)

	public static let icon: UIImage? = {
		return Base64ImageString.icon.image
	}()
	public static let logo: UIImage? = {
		return Base64ImageString.logo.image
	}()
	public static let cancel: UIImage? = {
		return Base64ImageString.cancel.image
	}()

	public static let rightArrow: UIImage? = {
		return UIImage(bundleNamed: "right_arrow")
	}()

	public static let vsSignature: UIImage? = {
		return Base64ImageString.vsSignature.image
	}()

	public static let errorHanger: UIImage? = {
		return UIImage(bundleNamed: "error_hanger")
	}()

	/// Gets the product placeholder image by the product type and style
	///
	/// - Parameters:
	///   - productType: The product type, which is fetched from the store product info
	///   - style: The product style, which is fetched from the store product info
	/// - Returns: The  product type placeholder`UIImage`
	internal static func getProductPlaceholderImage(productType: Int, style: String? = nil) -> UIImage? {
		var placeholderImage = UIImage(bundleNamed: "\(productType)")
		if let style = style,
		   let productTypeWithStyleImage = UIImage(bundleNamed: "\(productType)_\(style)") {
			placeholderImage = productTypeWithStyleImage
		}
		return placeholderImage
	}
}
