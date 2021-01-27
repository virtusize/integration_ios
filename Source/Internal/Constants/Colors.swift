//
//  Colors.swift
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

/// The Virtusize themed colors used in the Virtusize SDK
public extension UIColor {
	static var vsGray900Color: UIColor { #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1) }
	static var vsGray900PressedColor: UIColor { #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1) }
	static var vsTealColor: UIColor { #colorLiteral(red: 0.2431372549, green: 0.8235294118, blue: 0.7294117647, alpha: 1) }
	static var vsTealPressedColor: UIColor { #colorLiteral(red: 0.4784313725, green: 0.8549019608, blue: 0.7490196078, alpha: 1) }
}

import SwiftUI

@available(iOSApplicationExtension 13.0, *)
public extension Color {
	static var vsGray900Color: Color { Color(UIColor.vsGray900Color) }
	static var vsGray900PressedColor: Color { Color(UIColor.vsGray900PressedColor) }
	static var vsTealColor: Color { Color(UIColor.vsTealColor) }
	static var vsTealPressedColor: Color { Color(UIColor.vsTealPressedColor) }
}
