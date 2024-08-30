//
//  VirtusizeColors.swift
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

#if canImport(SwiftUI)
import SwiftUI

#if (arch(arm64) || arch(x86_64))
@available(iOS 13.0, *)
public extension Color {
	static var vsGray900Color: Color { Color(UIColor.vsGray900Color) }
	static var vsGray900PressedColor: Color { Color(UIColor.vsGray900PressedColor) }
	static var vsGray800Color: Color { Color(UIColor.vsGray800Color) }
	static var vsGray700Color: Color { Color(UIColor.vsGray700Color) }
	static var vsGray400Color: Color { Color(UIColor.vsGray400Color) }
	static var vsGray300Color: Color { Color(UIColor.vsGray300Color) }
	static var vsGray200Color: Color { Color(UIColor.vsGray200Color) }
	static var vsTealColor: Color { Color(UIColor.vsTealColor) }
	static var vsTealPressedColor: Color { Color(UIColor.vsTealPressedColor) }
	static var vsGrdPrimaryDarkColor: Color { Color(UIColor.vsGrdPrimaryDarkColor) }
	static var vsShadowColor: Color { Color(UIColor.vsShadowColor) }
	static var vsOverlayColor: Color { Color(UIColor.vsOverlayColor) }
}
#endif

#endif

/// The Virtusize themed colors used in the Virtusize SDK
public extension UIColor {
	static var vsGray900Color: UIColor { #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) }
	static var vsGray900PressedColor: UIColor { #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1) }
	static var vsGray800Color: UIColor { #colorLiteral(red: 0.4980392157, green: 0.5137254902, blue: 0.5137254902, alpha: 1) }
	static var vsGray700Color: UIColor { #colorLiteral(red: 0.7176470588, green: 0.7254901961, blue: 0.7254901961, alpha: 1) }
	static var vsGray400Color: UIColor { #colorLiteral(red: 0.7176470588, green: 0.7254901961, blue: 0.7254901961, alpha: 1) }
	static var vsGray300Color: UIColor { #colorLiteral(red: 0.9294117647, green: 0.9294117647, blue: 0.9294117647, alpha: 1) }
	static var vsGray200Color: UIColor { #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) }
	static var vsTealColor: UIColor { #colorLiteral(red: 0.2431372549, green: 0.8235294118, blue: 0.7294117647, alpha: 1) }
	static var vsTealPressedColor: UIColor { #colorLiteral(red: 0.4784313725, green: 0.8549019608, blue: 0.7490196078, alpha: 1) }
	static var vsGrdPrimaryDarkColor: UIColor { #colorLiteral(red: 0.0862745098, green: 0.7764705882, blue: 0.7254901961, alpha: 1) }
	static var vsShadowColor: UIColor { #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12) }
	static var vsOverlayColor: UIColor { #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6049972756) }
}