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

import Foundation

class Font {
    private enum FontWeight: String {
        case regular = "-Regular"
    }

    private enum FontName: String {
        case proximaNova = "ProximaNova"
        case notoSansCJKJP = "NotoSansCJKJP"
        case notoSansCJKKR = "NotoSansCJKKR"
    }

    static func proximaNovaRegular(size: CGFloat) -> UIFont {
        return font(fontName: .proximaNova, type: "otf", weight: .regular, size: size)
    }

    static func notoSansCJKJPRegular(size: CGFloat) -> UIFont {
        return font(fontName: .notoSansCJKJP, type: "ttf", weight: .regular, size: size)
    }

    static func notoSansCJKKRRegular(size: CGFloat) -> UIFont {
        return font(fontName: .notoSansCJKKR, type: "otf", weight: .regular, size: size)
    }

    private static func font(fontName: FontName, type: String, weight: FontWeight, size: CGFloat) -> UIFont {
        let fontFileName = fontName.rawValue + weight.rawValue
        var font = UIFont(name: fontFileName, size: size)

        if let existedFont = font {
            return existedFont
        }

        if register(fontFileName: fontFileName, type: type, bundle: Bundle(for: self)) {
            font = UIFont(name: fontFileName, size: size)
        }

        return font ?? UIFont.systemFont(ofSize: size)
    }

    private static func register(fontFileName: String, type: String, bundle: Bundle?) -> Bool {
        guard
            let bundle = bundle,
            let path = bundle.path(forResource: fontFileName, ofType: type),
            let data = NSData(contentsOfFile: path),
            let dataProvider = CGDataProvider(data: data),
            let fontReference = CGFont(dataProvider)
            else {
                return false
        }

        var errorRef: Unmanaged<CFError>?

        return !(CTFontManagerRegisterGraphicsFont(fontReference, &errorRef) == false)
    }
}
