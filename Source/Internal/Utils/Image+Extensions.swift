//
//  Image+Extensions.swift
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

internal extension UIImage {

    /// Creates a `UIImage` object in the Virtusize framework bundle.
    ///
    /// - Parameter name: The image name.
    convenience init?(bundleNamed name: String) {
		self.init(named: name, in: BundleLoader.virtusizeResourceBundle, compatibleWith: nil)
    }

    /// Adds the padding to a `UIImage`
    ///
    /// - Parameter inset: the padding in CGFloat
    func withPadding(inset: CGFloat) -> UIImage? {
        return withInsets(insets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
    }

    private func withInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        guard let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}

internal extension UIImageView {

    /// Loads the image from a URL
    ///
    /// - Parameters:
    ///   - url: The image URL
    ///   - success: The successful callback to pass the loaded image
    ///   - failure: The failure callback
    func load(url: URL, success: ((UIImage) -> Void)? = nil, failure: (() -> Void)? = nil) {
		DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    success?(image)
                }
            } else {
                DispatchQueue.main.async {
                    failure?()
                }
            }
        }
    }
}
