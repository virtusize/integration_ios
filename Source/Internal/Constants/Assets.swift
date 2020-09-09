//
//  Assets.swift
//
//  Copyright (c) 2018-20 Virtusize KK
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

/// This enum contains images encoded as Base64 strings
private enum Base64ImageString: String {
    // swiftlint:disable line_length
    case cancel = "cancel-umbrella"
    case cancel2x = """
    data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAACcSURBVHgBrZUBCoAgEASXPur+3Cf0BMtIiDK9u3XhRFRmBBUBIJ21n5XvvpoPr3bKoxRJerGq6GrKAknqcOrmwc6EV5J+GGwLFMkUrkjM8IjEDfdIwnCLRIbPJEvgHgkhhgp8wzwlOGfK34Fa34kMD0tGV5GqZARvCUss8LDEA3dLInCzRIGbJFmEjyTdP5mIhy9WboP5FhF6+OQdf/rpT78B4McAAAAASUVORK5CYII=
    """
    case cancel3x = """
    data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACQAAAAkCAYAAADhAJiYAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAADkSURBVHgBzdhRCoNADATQoRfv3kBvkNxwj7CtrbZg7bqbzQQHAn5E5oHgR4B37s/J60yIy2Hv8lB2I+BHDnoTVl0JRsmfzlwDsVBS6XuBUmXBGyUnXfO2qAGoM4zuX2CiujFMlBnDQA1jPFFuGA+UO2YERcNYUHRMDyoM04oKxYygFOTolTA9KIUhN9hSnHZcImj/ZAJyejB0lAVDQ7X89DQK1YLZQkf1YOgoC4aGGsG4ozwwbihPzDCKgTGjmJhu1BSAaUWlZSkHYVpQ1euHghetgVIwpob6XD9mfE9rCXH56X0AT2z7ZCahUZ0AAAAASUVORK5CYII=
    """
    case icon = "icon-umbrella"
    case icon2x = """
    data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAAAwCAMAAACWlYwtAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAABCUExURQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI7h9vIAAAAVdFJOUwAQIDBAUF9gb3B/gI+Qn6Cvv8/f7w6Awy0AAAFlSURBVEjH7ZXBdoQgDEUvGaYWUSpG//9Xu5CeQWUYtbt23jYhnJdcArz1l/Q1Z5pknyBTnhF2caMWuKd43BeIKdQAjRZusJMAfUpz23CbXS1qSyb6CBgtm5B0XgUIvtgFMzrApsxxHUx1Zwt86pM+iuYmfMmAB6TU4kVuBMyYkm8FAwDqn88ydsAtzUvNzoAAbazAIJMFXErvigZUajjd1WQjT8OyGRxGmzqQfZdBt5j4mawK0IUXRBu9b010rxAsATk8TDSvEawAqUZyA4M/8i5XQA4hM/AUwRqQST0gsxxbDQuQmp9XA6g7ulwWIPMCArTD4e20BjIheFM5vt/WQM56BMEKkJMAIZxasSsgHdBkb/OQFiDjA0E5u+b7mEyoANGf/yhGt6z5Bmj1wk+TgAz1LVgH0oA5h2ABSKAN185jJgtgVS4WwKoBOYfgZpYBQv+LP9/ox2kEt0Beb8Ai73nrH+gbv50ive8VQssAAAAASUVORK5CYII=
    """
    case icon3x = """
    data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABICAMAAAA+uQBRAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAABCUExURQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI7h9vIAAAAVdFJOUwAQIDBAUF9gb3B/gI+Qn6Cvv8/f7w6Awy0AAAIASURBVFjD7ZjbdoQgDEUVsdbxUhH4/1/tg0EDhIuKL63nadaaJGQO2YJTVa9evfpj6gdfXTylO5XCNSEerU9lRHqaoFyDwmUdjmcSBTJYcoo0VEso16PEORw/o7ABlow1VFVcL9sHgVLbHINWsyRL7LPut07UkatY2iCI+YYfEpGAUGySSBtk2pLJUWUKyi1eesQg2CepWAYMUK5OmIRNlNv3H7oTVwvMKo+bJLzJZ7GBo2Z1ipn0QV9OJo/lPTG4HiEjbBLzURx1l/tMmgiTVjvkLMKuSco3aQgZlIewrcbs6ooKNQGDMhFOA4069A3KQDgN9EgZZBpZT549e4bwjwa898sJhF2TxoBJeHp3hLvqtAzQrWvSeBnhDKA59YzLRzgNtKyZb9AYPpJSQLf+ps7epndnJxQDzTyTKIQv35MM0PVK1b+GMA10o4gFLiKcBto2SIlbl0kSaHzGXZxQfLL7QN9F2NYPDGNP3T+bSwgHgMbXmJsIZwDNYEJ5ibcGAujuJsKOSasL9HQbYQdomHVj0r4prNACB9AFEY4ADQhrUa6+BbQshLCtdgdaFUOYvk32PYzsXLb+AbSZUFZ4AbvnQgi7Jn0dj9ihekAG6IIIB14PhWaPLGCA/jxj0AZ0UxphD+i6emBCLaCLI+zOanGEY0A/Id68/zy+evUP9Qt/5k42pprh/gAAAABJRU5ErkJggg==
    """
    case logo = "logo-umbrella"
    case logo2x = """
    data:image/png;base64,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
    """
    case logo3x = """
    data:image/png;base64,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
    """

    // swiftlint:enable line_length
    var image: UIImage? {
        let scale = UIScreen.main.scale
        let value: String
        switch self {
        case .cancel:
            if scale == 3.0 {
                value = Base64ImageString.cancel3x.rawValue
            } else {
                value = Base64ImageString.cancel2x.rawValue
            }
        case .icon:
            if scale == 3.0 {
                value = Base64ImageString.icon3x.rawValue
            } else {
                value = Base64ImageString.icon2x.rawValue
            }
        case .logo:
            if scale == 3.0 {
                value = Base64ImageString.logo3x.rawValue
            } else {
                value = Base64ImageString.logo2x.rawValue
            }
        default:
            value = self.rawValue
        }
        let temp = value.components(separatedBy: ",")
        let dataDecoded: Data = Data(base64Encoded: temp[1], options: .ignoreUnknownCharacters)!
        return UIImage(data: dataDecoded, scale: scale)
    }
}

/// This class wraps the assets including colors and images used in the Virtusize SDK
final internal class Assets {
    private static let bundle = Bundle(for: Assets.self)

    internal static let icon: UIImage? = {
        return Base64ImageString.icon.image
    }()
    internal static let logo: UIImage? = {
        return Base64ImageString.logo.image
    }()
    internal static let cancel: UIImage? = {
        return Base64ImageString.cancel.image
    }()

    internal static let rightArrow: UIImage? = {
        return UIImage(bundleNamed: "right_arrow")
    }()

    internal static let vsSignature: UIImage? = {
           return UIImage(bundleNamed: "vs_signature")
       }()

    internal static let errorHanger: UIImage? = {
        return UIImage(bundleNamed: "error_hanger")
    }()

    static func getProductPlaceholderImage(productType: Int, style: String? = nil) -> UIImage? {
        var placeholderImage = UIImage(bundleNamed: "\(productType)")
        if let style = style,
            let productTypeWithStyleImage = UIImage(bundleNamed: "\(productType)_\(style)") {
            placeholderImage = productTypeWithStyleImage
        }
        return placeholderImage
    }
}
