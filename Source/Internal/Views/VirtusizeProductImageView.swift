//
//  VirtusizeProductImageView.swift
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

internal class VirtusizeProductImageView: UIView {

    private var imageSize: CGFloat = 40

    private var productImageView: UIImageView = UIImageView()

    var image: UIImage? {
        set {
            if productImageView.image != newValue {
                productImageView.image = newValue
                setStyle()
            }
        }
        get {
            return productImageView.image
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    init(size: CGFloat) {
        super.init(frame: .zero)
        imageSize = size
        setup()
    }

    private func setup() {
        addSubview(productImageView)

        frame.size = CGSize(width: imageSize, height: imageSize)
        layer.cornerRadius = imageSize / 2
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor

        setStyle()
    }

    private func setStyle() {
        productImageView.center = center
        productImageView.frame.size = CGSize(width: imageSize - 4, height: imageSize - 4)
        productImageView.layer.cornerRadius = (imageSize - 4) / 2
        productImageView.backgroundColor = UIColor.gray
        productImageView.layer.masksToBounds = true
        productImageView.contentMode = .scaleAspectFit
    }
}
