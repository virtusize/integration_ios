//
//  VirtusizeTypography.swift
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

// swiftlint:disable switch_case_alignment
public struct VirtusizeTypography {
	let language: VirtusizeUILanguage

	public init(language: VirtusizeUILanguage = .ENGLISH) {
		self.language = language
	}

	public var headline1Font: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 48, weight: .medium)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 44, weight: .medium)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 44, weight: .medium)
		}
	}

	public var headline2Font: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 36, weight: .medium)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 32, weight: .medium)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 32, weight: .medium)
		}
	}

	public var headline3Font: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 30, weight: .medium)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 27, weight: .medium)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 27, weight: .medium)
		}
	}

	public var headline4Font: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 24, weight: .medium)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 21, weight: .medium)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 21, weight: .medium)
		}
	}

	public var headline5Font: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 18, weight: .medium)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 17, weight: .medium)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 17, weight: .medium)
		}
	}

	public var headline6Font: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 16, weight: .medium)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 14, weight: .medium)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 14, weight: .medium)
		}
	}

	public var bodyFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 16)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 14)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 14)
		}
	}

	public var boldFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 16, weight: .bold)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 14, weight: .bold)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 14, weight: .bold)
		}
	}

	public var xxLargeFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 28)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 24)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 24)
		}
	}

	public var xxLargeBoldFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 28, weight: .bold)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 24, weight: .bold)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 24, weight: .bold)
		}
	}

	public var xLargeFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 22)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 20)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 20)
		}
	}

	public var xLargeBoldFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 22, weight: .bold)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 20, weight: .bold)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 20, weight: .bold)
		}
	}

	public var largeFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 18)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 16)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 16)
		}
	}

	public var largeBoldFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 18, weight: .bold)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 16, weight: .bold)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 16, weight: .bold)
		}
	}

	public var normalFont: UIFont {
		return bodyFont
	}

	public var normalBoldFont: UIFont {
		return boldFont
	}

	public var smallFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 14)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 12)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 12)
		}
	}

	public var smallBoldFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 14, weight: .bold)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 12, weight: .bold)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 12, weight: .bold)
		}
	}

	public var xSmallFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 12)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 10)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 10)
		}
	}

	public var xSmallBoldFont: UIFont {
		switch language {
			case .ENGLISH:
				return VirtusizeFont.system(size: 12, weight: .bold)
			case .JAPANESE:
				return VirtusizeFont.notoSansCJKJP(size: 10, weight: .bold)
			case .KOREAN:
				return VirtusizeFont.notoSansCJKKR(size: 10, weight: .bold)
		}
	}
}
