//
//  Localization.swift
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

import Foundation
#if SWIFT_PACKAGE
import VirtusizeCore
#endif

/// This class is used to localize texts in the SDK
internal class Localization {

	static let shared: Localization = Localization()

	/// Localizes a text corresponding to a key
	///
	/// - Parameters:
	///   - key: The key for a string in the table identified by tableName.
	///   - language: Pass `VirtusizeLanguage` if you'd like to localize the text in a designated language
	/// - Returns: A localized string based on the device's default language
	func localize(_ key: String, language: VirtusizeLanguage? = nil) -> String {
		return VirtusizeCoreBundleLoader.localizationBundle(
			language: language?.rawValue ?? Virtusize.params?.language.rawValue
		).localizedString(
			forKey: key, value: nil, table: "VirtusizeLocalizable"
		)
	}
}
