//
//  VirtusizeFont.swift
//  VirtusizeUIKit
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
internal class VirtusizeFont {

	/// This enum contains all available font weights used in this SDK
	public enum FontWeight: String {
		case regular = "-Regular"
		case medium = "-Medium"
		case bold = "-Bold"

		var uiFontWeight: UIFont.Weight {
			// swiftlint:disable switch_case_alignment
			switch self {
				case .regular:
					return .regular
				case .medium:
					return .medium
				case .bold:
					return .bold
			}
		}
	}

	/// This enum contains all available font names used in this SDK
	private enum FontName: String {
		case notoSansCJKJP = "NotoSansCJKJP"
		case notoSansCJKKR = "NotoSansCJKKR"
	}

	public static func system(size: CGFloat, weight: FontWeight = .regular) -> UIFont {
		return UIFont.systemFont(ofSize: size, weight: weight.uiFontWeight)
	}

	public static func notoSansCJKJP(size: CGFloat, weight: FontWeight = .regular) -> UIFont {
		return font(fontName: .notoSansCJKJP, type: "otf", weight: weight, size: size)
	}

	public static func notoSansCJKKR(size: CGFloat, weight: FontWeight = .regular) -> UIFont {
		return font(fontName: .notoSansCJKKR, type: "otf", weight: weight, size: size)
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
