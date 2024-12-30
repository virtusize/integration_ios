//
//  VirtusizeLanguage.swift
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

/// This enum contains all the possible display languages of the Virtusize web app
public enum VirtusizeLanguage: String, CaseIterable {
	case ENGLISH = "en"
	case JAPANESE = "ja"
	case KOREAN = "ko"

	/// A two character lang string (For the Flutter SDK)
	public var langStr: String {
		switch self {
		case .ENGLISH:
			return "EN"
		case .JAPANESE:
			return  "JP"
		case .KOREAN:
			return  "KR"
		}
	}

	/// The default label for the language selector
	var label: String {
		switch self {
		case .ENGLISH:
			return "English"
		case .JAPANESE:
			return  "日本語"
		case .KOREAN:
			return  "한국어"
		}
	}
}
