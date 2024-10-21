//
//  BundleLoaderProtocol.swift
//  VirtusizeCore
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

import Foundation

public protocol BundleLoaderProtocol {
	static var bundleClass: AnyClass { get }
	#if SWIFT_PACKAGE
	static var spmResourceBundle: Bundle { get }
	#endif
}

public extension BundleLoaderProtocol {
	/// The bundle is used for resources like images
    /// - Parameter bundleName: The resource bundle name
    static func resourceBundle(bundleName: String) -> Bundle {
		var bundle: Bundle?
		// Swift Package Manager bundle
		#if SWIFT_PACKAGE
		bundle = spmResourceBundle
		#endif

		if bundle == nil {
			// name.bundle
			bundle = Bundle(path: "\(bundleName).bundle")
		}

		if bundle == nil {
			// name.framework/name.bundle
			if let path = Bundle(for: bundleClass).path(forResource: bundleName, ofType: "bundle") {
				bundle = Bundle(path: path)
			}
		}

		if bundle == nil {
			// name.framework
			bundle = Bundle(for: bundleClass)
		}

		if let bundle = bundle {
			return bundle
		} else {
			// Fallback to Bundle.main to ensure there is always a bundle.
			return Bundle.main
		}
	}

	/// Gets the bundle that is used for localization
	/// - Parameter
    /// - Parameters:
    ///   - bundleName: The resource bundle name
    ///   - language: `VirtusizeLanguage`
    static func localizationBundle(bundleName: String, language: String? = nil) -> Bundle {
        var bundle = resourceBundle(bundleName: bundleName)
		if let localizableBundlePath = bundle.path(
			forResource: language,
			ofType: "lproj"
		),
		let localizableBundle = Bundle(path: localizableBundlePath) {
			bundle = localizableBundle
		}
		return bundle
	}
}
