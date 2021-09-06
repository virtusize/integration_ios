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
		static let bubbleRadius = CGFloat(10)
		static let closeCrossSize = CGFloat(12)
		static let closeCrossPadding = CGFloat(10)
		static let windowEdgeToTooltipMargin = CGFloat(16)
		static let anchorViewToTooltipMargin = CGFloat(5)
	}

	private lazy var dismissView: UIView = {
		   let view = UIView()

		   view.backgroundColor = .clear
		   view.frame = UIScreen.main.bounds

		   return view
	   }()

	private lazy var textSize: CGSize = {
		var attributes = [NSAttributedString.Key.font: params.font]

		var maxTextSizeWidth: CGFloat

		switch params.position {
			case .bottom:
				maxTextSizeWidth = UIScreen.main.bounds.width
					- Constants.bubblePadding * 2
					- Constants.windowEdgeToTooltipMargin * 2
			case .left:
				maxTextSizeWidth = params.anchorView!.frame.origin.x
					- Constants.anchorViewToTooltipMargin
					- Constants.arrowHeight
					- Constants.bubblePadding * 2
					- Constants.windowEdgeToTooltipMargin
			default:
				maxTextSizeWidth = 0
		}

		if params.showCloseButton {
			maxTextSizeWidth -= (Constants.closeCrossSize + Constants.closeCrossPadding)
		}

		var textSize = params.text.boundingRect(
			with:
				CGSize(
					width: maxTextSizeWidth,
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
		var width: CGFloat
		var height: CGFloat

		switch params.position {
			case .bottom:
				width = textSize.width + Constants.bubblePadding * 2
				height = textSize.height + Constants.bubblePadding * 2 + Constants.arrowHeight
			case .left:
				width = textSize.width + Constants.bubblePadding * 2 + Constants.arrowHeight
				height = textSize.height + Constants.bubblePadding * 2
			default:
				width = 0
				height = 0
		}

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

		let updatedX: CGFloat
		let updatedY: CGFloat

		switch params.position {
			case .bottom:
				updatedX = anchorViewFrame.center.x - contentSize.width / 2
				updatedY = anchorViewFrame.origin.y + anchorViewFrame.height + Constants.anchorViewToTooltipMargin
			case .left:
				updatedX = anchorViewFrame.origin.x - contentSize.width - Constants.anchorViewToTooltipMargin
				updatedY = anchorViewFrame.center.y - contentSize.height / 2
			default:
				updatedX = 0
				updatedY = 0
		}

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
		if params.showCloseButton {
			drawCloseCross(to: context, rect)
		}
		drawArrow(to: context, rect)
		drawText(to: context, rect)
	}

	private func drawBubble(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		let path = UIBezierPath()

		var leftX: CGFloat = 0
		var bottomY: CGFloat = 0

		switch params.position {
			case .bottom:
				bottomY = Constants.arrowHeight
			case .left:
				leftX = -Constants.arrowHeight
			default:
				leftX = 0
				bottomY = 0
		}

		let radius = Constants.bubbleRadius

		// top left corner
		path.addArc(
			withCenter: CGPoint(x: radius, y: radius + bottomY),
			radius: radius,
			startAngle: CGFloat.pi,
			endAngle: CGFloat.pi * 3 / 2,
			clockwise: true
		)
		// top right corner
		path.addArc(
			withCenter: CGPoint(x: rect.width - radius + leftX, y: radius + bottomY),
			radius: radius,
			startAngle: CGFloat.pi * 3 / 2,
			endAngle: 0,
			clockwise: true
		)
		// bottom right corner
		path.addArc(
			withCenter: CGPoint(x: rect.width - radius + leftX, y: rect.height - radius),
			radius: radius,
			startAngle: 0,
			endAngle: CGFloat.pi / 2,
			clockwise: true
		)
		// bottom left corner
		path.addArc(
			withCenter: CGPoint(x: radius, y: rect.height  - radius),
			radius: radius,
			startAngle: CGFloat.pi / 2,
			endAngle: CGFloat.pi,
			clockwise: true
		)

		path.close()

		context.addPath(path.cgPath)
		context.clip()

		context.setFillColor(UIColor.vsGray900Color.cgColor)
		context.fill(rect)

		context.restoreGState()
	}

	private func drawCloseCross(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		let closeCrossX: CGFloat
		let closeCrossY: CGFloat

		switch params.position {
			case .bottom:
				closeCrossX = rect.maxX - Constants.bubblePadding - Constants.closeCrossSize
				closeCrossY = rect.minY + Constants.arrowHeight + Constants.closeCrossPadding
			case .left:
				closeCrossX = rect.maxX
					- Constants.arrowHeight
					- Constants.bubblePadding
					- Constants.closeCrossSize
				closeCrossY = Constants.bubblePadding
			default:
				closeCrossX = 0
				closeCrossY = 0
		}

		context.draw(
			VirtusizeAssets.whiteClose!.cgImage!,
			in: CGRect(
				x: closeCrossX,
				y: closeCrossY,
				width: Constants.closeCrossSize,
				height: Constants.closeCrossSize
			)
		)

		context.restoreGState()
	}

	private func drawArrow(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		context.beginPath()

		switch params.position {
			case .bottom:
				context.move(to: CGPoint(x: rect.center.x, y: rect.minY))
				context.addLine(to: CGPoint(x: rect.center.x - Constants.arrowWidth / 2, y: rect.minY + Constants.arrowHeight))
				context.addLine(to: CGPoint(x: rect.center.x + Constants.arrowWidth / 2, y: rect.minY + Constants.arrowHeight))
			case .left:
				// draw an arrow on the right
				context.move(to: CGPoint(x: rect.width - Constants.arrowHeight + Constants.arrowHeight, y: rect.center.y))
				context.addLine(to: CGPoint(x: rect.width - Constants.arrowHeight, y: rect.center.y - Constants.arrowWidth / 2))
				context.addLine(to: CGPoint(x: rect.width - Constants.arrowHeight, y: rect.center.y + Constants.arrowWidth / 2))
			default:
				break
		}

		context.closePath()

		context.setFillColor(UIColor.vsGray900Color.cgColor)
		context.fillPath()

		context.restoreGState()
	}

	private func drawText(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		var shiftX: CGFloat = 0
		var shiftY: CGFloat = 0

		switch params.position {
			case .bottom:
				shiftY = Constants.arrowHeight
			case .left:
				break
			default:
				break
		}

		if params.showCloseButton {
			shiftX += Constants.closeCrossSize / 2
			shiftY += Constants.closeCrossSize / 2
		}

		let textRect = CGRect(
			x: rect.origin.x + Constants.bubblePadding + shiftX,
			y: rect.origin.y + Constants.bubblePadding + shiftY,
			width: textSize.width,
			height: textSize.height
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
