//
//  VirtusizeUITooltip.swift
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

public class VirtusizeUITooltip: UIView {
	private(set) var params: VirtusizeUITooltipParams
	private var container: UIWindow?

	struct Constant {
		static let arrowWidth = CGFloat(13)
		static let arrowHeight = CGFloat(7)
		static let windowEdgeToTooltipMargin = CGFloat(16)
		static let maxTooltipWidth = UIScreen.main.bounds.width - windowEdgeToTooltipMargin
	}

	private lazy var dismissView: UIView = {
		   let view = UIView()

		   view.backgroundColor = .clear
		   view.frame = UIScreen.main.bounds

		   return view
	   }()

	private lazy var bubbleSize: CGSize = {
		var attributes = [NSAttributedString.Key.font: params.font]

		var textSize = params.text.boundingRect(
			with:
				CGSize(
					width: Constant.maxTooltipWidth,
					height: .greatestFiniteMagnitude
				),
			options: .usesLineFragmentOrigin,
			attributes: attributes,
			context: nil)
			.size

		textSize.width = ceil(textSize.width)
		textSize.height = ceil(textSize.height)

		return textSize

		}()

	private lazy var contentSize: CGSize = {
		// bottom
		let width = bubbleSize.width
		let height = Constant.arrowHeight + bubbleSize.height

		return CGSize(width: width, height: height)
	}()

	public enum Position {
		case top
		case bottom
		case right
		case left
	}

	public init (params: VirtusizeUITooltipParams) {
		self.params = params

		super.init(frame: .zero)
	}

	@available(*, unavailable)
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented. Use init(builder:) instead.")
	}

	public func show() {
		// The initial frame size is 0. We need to update the frame of the tooltip
		updateFrame()

		params.anchorView!.superview?.addSubview(self)
		params.anchorView!.superview?.addSubview(dismissView)

		let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
		addGestureRecognizer(tap)
		dismissView.addGestureRecognizer(tap)
	}

	private func updateFrame() {
		let anchorViewFrame = params.anchorView!.convert(params.anchorView!.bounds, to: UIApplication.safeShared?.keyWindow)

		// Bottom
		let updatedX: CGFloat = anchorViewFrame.center.x - contentSize.width / 2
		let updatedY: CGFloat = anchorViewFrame.origin.y + anchorViewFrame.height

		frame = CGRect(
			x: updatedX,
			y: updatedY,
			width: contentSize.width,
			height: contentSize.height
		)
	}

	@objc func dismiss() {
		self.removeFromSuperview()
		self.dismissView.removeFromSuperview()
	}

	override open func draw(_ rect: CGRect) {
		super.draw(rect)

		guard let context = UIGraphicsGetCurrentContext() else { return }

		context.setFillColor(UIColor.vsGray900Color.cgColor)
		context.addRect(rect)
		context.drawPath(using: .fill)
		context.fill(rect)
	}
}
