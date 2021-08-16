//
//  BundleLoader.swift
//
//  Copyright (c) 2021-present Virtusize KK
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

/// The class is to access different types of bundles for the SDK
internal class BundleLoader: NSObject {
	/// The bundle is used for resources like images
	static var virtusizeResourceBundle: Bundle = {
		var bundle: Bundle?
		// Swift Package Manager bundle
		#if SWIFT_PACKAGE
		bundle = Bundle.module
		#endif

		if bundle == nil {
			// Virtusize.bundle
			bundle = Bundle(path: "Virtusize.bundle")
		}

		if bundle == nil {
			// Virtusize.framework/Virtusize.bundle
			if let path = Bundle(for: BundleLoader.self).path(forResource: "Virtusize", ofType: "bundle") {
				bundle = Bundle(path: path)
			}
		}

		if bundle == nil {
			// Virtusize.framework
			bundle = Bundle(for: BundleLoader.self)
		}

		if let bundle = bundle {
			return bundle
		} else {
			// Fallback to Bundle.main to ensure there is always a bundle.
			return Bundle.main
		}
	}()

	/// Gets the bundle that is used for localization
	/// - Parameter language: `VirtusizeLanguage`
	static func virtusizeLocalizationBundle(language: VirtusizeLanguage? = nil) -> Bundle {
		var bundle = virtusizeResourceBundle
		if let localizableBundlePath = bundle.path(
			forResource: language?.rawValue ?? Virtusize.params?.language.rawValue,
			ofType: "lproj"
		),
		let localizableBundle = Bundle(path: localizableBundlePath) {
			bundle = localizableBundle
		}
		return bundle
	}
}
