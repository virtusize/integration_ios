//
//  Font.swift
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

/// This class to used to get UIFonts from font files
class Font {

	/// This enum contains all available font weights used in this SDK
	internal enum FontWeight: String {
		case regular = "-Regular"
		case bold = "-Bold"

		var uiFontWeight: UIFont.Weight {
			if self == .regular {
				return .regular
			} else {
				return .bold
			}
		}
	}

	/// This enum contains all available font names used in this SDK
	private enum FontName: String {
		case notoSansJP = "Subset-NotoSansJP"
		case notoSansKR = "Subset-NotoSansKR"
	}

	static func system(size: CGFloat, weight: FontWeight = .regular) -> UIFont {
		return UIFont.systemFont(ofSize: size, weight: weight.uiFontWeight)
	}

	static func notoSansCJKJP(size: CGFloat, weight: FontWeight = .regular) -> UIFont {
		return font(fontName: .notoSansJP, type: "ttf", weight: weight, size: size)
	}

	static func notoSansCJKKR(size: CGFloat, weight: FontWeight = .regular) -> UIFont {
		return font(fontName: .notoSansKR, type: "ttf", weight: weight, size: size)
	}

	private static func font(fontName: FontName, type: String, weight: FontWeight, size: CGFloat) -> UIFont {
		let fontFileName = fontName.rawValue + weight.rawValue

		// Return the existed font matching the font name if the font was already registered (was not null) before
		if let existedFont = UIFont(name: fontFileName, size: size) {
			return existedFont
		}

		// Return the font if registering a font is successful
		if let registeredFont = register(
			fontFileName: fontFileName,
			type: type,
			size: size
		) {
			return registeredFont
		}

		// Fall back to the system font
		return system(size: size, weight: weight)
	}

	/// Registers a specified graphics font
	/// - Parameters:
	///   - fontFileName: The font file name
	///   - type: The font file type, such as `otf` or `ttf`
	///   - size: The font size
	/// - Returns: The registered font. If it fails to register a font, return nil
	private static func register(fontFileName: String, type: String, size: CGFloat) -> UIFont? {
		guard
			let path = Bundle(for: self).path(forResource: fontFileName, ofType: type),
			let data = NSData(contentsOfFile: path),
			let dataProvider = CGDataProvider(data: data),
			let fontReference = CGFont(dataProvider)
		else {
			return nil
		}

		var errorRef: Unmanaged<CFError>?

		if CTFontManagerRegisterGraphicsFont(fontReference, &errorRef) == true {
			return UIFont(name: fontFileName, size: size)
		} else {
			return nil
		}
	}
}
