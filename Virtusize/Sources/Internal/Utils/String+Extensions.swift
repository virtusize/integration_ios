//
//  String+Extensions.swift
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
import Foundation

internal extension NSAttributedString {
	/// Adds the line spacing to an attributed string
	///
	/// - Parameter spacing: The line spacing in CGFloat
	func lineSpacing(_ spacing: CGFloat) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(attributedString: self)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byTruncatingTail
		paragraphStyle.lineSpacing = spacing
		attributedString.addAttribute(
			.paragraphStyle,
			value: paragraphStyle,
			range: NSRange(location: 0, length: string.count)
		)
		return NSAttributedString(attributedString: attributedString)
	}
}

internal extension String {
	/// Trims the text from i18n localization
	///
	/// - Parameter trimType: `VirtusizeI18nLocalization.TrimType`
	func trimI18nText(
		_ trimType: VirtusizeI18nLocalization.TrimType = VirtusizeI18nLocalization.TrimType.ONELINE
	) -> String {
		return self.replacingOccurrences(of: "<br>", with: "")
			.replacingOccurrences(of: "%{boldStart}", with: trimType.rawValue)
            .replacingOccurrences(of: "%{boldEnd}", with: "")
    }

	/// Calculate the expected text height based on the width and the font of the string
	///
	/// - Parameters:
	///   - withConstrainedWidth: the text width
	///   - font: the text font
	/// - Returns: the ceiling of the expected text height
	func height(width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingRect = self.boundingRect(
			with: constraintRect,
			options: .usesLineFragmentOrigin,
			attributes: [.font: font],
			context: nil
		)
		return floor(boundingRect.height)
	}
}
