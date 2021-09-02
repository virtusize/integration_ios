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
import VirtusizeCore

public class VirtusizeUITooltip: UIView {
	private(set) var params: VirtusizeUITooltipParams
	private var container: UIWindow?

	private struct Constants {
		static let arrowWidth = CGFloat(13)
		static let arrowHeight = CGFloat(7)
		static let bubblePadding = CGFloat(10)
		static let windowEdgeToTooltipMargin = CGFloat(16)
		static let anchorViewToTooltipMargin = CGFloat(5)
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
					width: Constants.maxTooltipWidth,
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
		let width = bubbleSize.width + Constants.bubblePadding * 2
		let height = bubbleSize.height + Constants.arrowHeight + Constants.bubblePadding * 2

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

		backgroundColor = .clear
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
		let updatedY: CGFloat = anchorViewFrame.origin.y + anchorViewFrame.height + Constants.anchorViewToTooltipMargin

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

		drawBubble(to: context, rect)
		drawArrow(to: context, rect)
		drawText(to: context, rect)
	}

	private func drawBubble(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		let radius: CGFloat = 10
		let path = UIBezierPath()
		// bottom
		let additionalY = Constants.arrowHeight

		// top left corner
		path.addArc(
			withCenter: CGPoint(x: radius, y: radius + additionalY),
			radius: radius,
			startAngle: CGFloat.pi,
			endAngle: CGFloat.pi * 3 / 2,
			clockwise: true
		)
		// top right corner
		path.addArc(
			withCenter: CGPoint(x: bounds.width - radius, y: radius + additionalY),
			radius: radius,
			startAngle: CGFloat.pi * 3 / 2,
			endAngle: 0,
			clockwise: true
		)
		// bottom right corner
		path.addArc(
			withCenter: CGPoint(x: bounds.width - radius, y: bounds.height - radius),
			radius: radius,
			startAngle: 0,
			endAngle: CGFloat.pi / 2,
			clockwise: true
		)
		// bottom left corner
		path.addArc(
			withCenter: CGPoint(x: radius, y: bounds.height  - radius),
			radius: radius,
			startAngle: CGFloat.pi / 2,
			endAngle: CGFloat.pi,
			clockwise: true
		)

		path.close()

		context.addPath(path.cgPath)
		context.clip()

		context.setFillColor(UIColor.vsGray900Color.cgColor)
		context.fill(bounds)

		context.restoreGState()
	}

	private func drawArrow(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		context.beginPath()
		// bottom
		context.move(to: CGPoint(x: bounds.center.x, y: bounds.minY))
		context.addLine(to: CGPoint(x: bounds.center.x - Constants.arrowWidth / 2, y: bounds.minY + Constants.arrowHeight))
		context.addLine(to: CGPoint(x: bounds.center.x + Constants.arrowWidth / 2, y: bounds.minY + Constants.arrowHeight))
		context.closePath()

		context.setFillColor(UIColor.vsGray900Color.cgColor)
		context.fillPath()
		context.closePath()

		context.restoreGState()
	}

	private func drawText(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		// bottom
		let additionalY = Constants.arrowHeight

		let textRect = CGRect(
			x: rect.origin.x + Constants.bubblePadding,
			y: rect.origin.y + Constants.bubblePadding + additionalY,
			width: contentSize.width,
			height: contentSize.height
		)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .left
		paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping

		let attributes = [
			NSAttributedString.Key.font: params.font,
			NSAttributedString.Key.foregroundColor: UIColor.white,
			NSAttributedString.Key.paragraphStyle: paragraphStyle
		]

		params.text.draw(in: textRect, withAttributes: attributes)

		context.restoreGState()
	}
}
