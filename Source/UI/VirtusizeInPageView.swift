//
//  VirtusizeInPageView.swift
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
public class VirtusizeInPageView: UIView, VirtusizeView {

    /// The property to set the Virtusize view style that this SDK provides
    public var style: VirtusizeViewStyle = VirtusizeViewStyle.NONE {
        didSet {
            setup()
        }
    }

    public var presentingViewController: UIViewController?
    public var messageHandler: VirtusizeMessageHandler?
    public func setInPageText() {}

    internal let defaultMargin: CGFloat = 8

    internal var timer: Timer?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isHidden = true
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        isHidden = true
        setup()
    }

    internal func setup() {}

    internal func setHorizontalMargins(view: UIView, margin: CGFloat) {
        view.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: margin
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: margin
            )
        )
    }

    @objc internal func clickInPageViewAction() {
        openVirtusizeWebView()
    }

    internal func startLoadingAnimation(label: UILabel, text: String) {
        var tempDots = 0
        label.text = text
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if tempDots == 3 {
                tempDots = 0
                label.text = text
            } else {
                tempDots += 1
                label.text = "\(text)" + String(repeating: "·", count: tempDots)
            }
        }
    }

    internal func stopLoadingAnimation() {
        timer?.invalidate()
    }
}
