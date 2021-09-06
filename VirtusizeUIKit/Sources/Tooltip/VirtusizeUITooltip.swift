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
		static let tipWidth = CGFloat(13)
		static let tipHeight = CGFloat(7)
		static let bubblePadding = CGFloat(10)
		static let bubbleRadius = CGFloat(10)
		static let borderWidth = CGFloat(1)
		static let closeCrossSize = CGFloat(12)
		static let closeCrossPadding = CGFloat(10)
		static let windowEdgeToTooltipMargin = CGFloat(16)
		static let anchorViewToTooltipMargin = CGFloat(5)
	}

	private lazy var dismissView: UIView = {
		   let view = UIView()

		view.backgroundColor = params.showOverlay ? .vsOverlayColor : .clear
		   view.frame = UIScreen.main.bounds

		   return view
	   }()

	private lazy var textSize: CGSize = {
		var attributes = [NSAttributedString.Key.font: params.font]

		var maxTextSizeWidth: CGFloat

		switch params.position {
			case .top, .bottom:
				maxTextSizeWidth = UIScreen.main.bounds.width
					- Constants.bubblePadding * 2
					- Constants.windowEdgeToTooltipMargin * 2
			case .left:
				maxTextSizeWidth = params.anchorView.frame.origin.x
					- Constants.anchorViewToTooltipMargin
					- Constants.bubblePadding * 2
					- Constants.windowEdgeToTooltipMargin

				if params.showTip {
					maxTextSizeWidth -= Constants.tipHeight
				}
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
			case .top, .bottom:
				width = textSize.width + Constants.bubblePadding * 2
				height = textSize.height + Constants.bubblePadding * 2

				if params.showTip {
					height += Constants.tipHeight
				}
			case .left:
				width = textSize.width + Constants.bubblePadding * 2
				height = textSize.height + Constants.bubblePadding * 2

				if params.showTip {
					width += Constants.tipHeight
				}
			default:
				width = 0
				height = 0
		}

		if params.showCloseButton {
			width += Constants.closeCrossSize + Constants.closeCrossPadding * 2
			height += Constants.closeCrossSize
		}

		return CGSize(width: width, height: height)
	}()

	public enum Position {
		// TODO: Implement the right position
		case top
		case bottom
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

		params.anchorView.superview?.addSubview(dismissView)
		params.anchorView.superview?.addSubview(self)

		let dismissViewTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
		dismissView.addGestureRecognizer(dismissViewTap)
		let tooltipTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
		addGestureRecognizer(tooltipTap)
	}

	private func updateFrame() {
		let anchorViewFrame = params.anchorView.convert(params.anchorView.bounds, to: UIApplication.safeShared?.keyWindow)

		let updatedX: CGFloat
		let updatedY: CGFloat

		switch params.position {
			case .top:
				updatedX = anchorViewFrame.center.x - contentSize.width / 2
				updatedY = anchorViewFrame.origin.y - Constants.anchorViewToTooltipMargin - contentSize.height
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

		drawTooltipBody(to: context, rect)
		if params.showCloseButton {
			drawCloseCross(to: context, rect)
		}

		if params.showTip {
			drawTip(to: context, rect)
		}
		drawText(to: context, rect)
	}

	private func drawTooltipBody(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		let path = UIBezierPath()

		var leftX: CGFloat = 0
		var topY: CGFloat = 0
		var bottomY: CGFloat = 0

		if params.showTip {
			switch params.position {
				case .top:
					topY = -Constants.tipHeight
				case .bottom:
					bottomY = Constants.tipHeight
				case .left:
					leftX = -Constants.tipHeight
				default:
					leftX = 0
					bottomY = 0
			}
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
			withCenter: CGPoint(x: rect.width - radius + leftX, y: rect.height - radius + topY),
			radius: radius,
			startAngle: 0,
			endAngle: CGFloat.pi / 2,
			clockwise: true
		)
		// bottom left corner
		path.addArc(
			withCenter: CGPoint(x: radius, y: rect.height  - radius + topY),
			radius: radius,
			startAngle: CGFloat.pi / 2,
			endAngle: CGFloat.pi,
			clockwise: true
		)

		path.close()

		context.addPath(path.cgPath)
		context.clip()

		if params.showInvertedStyle {
			context.setFillColor(UIColor.white.cgColor)
			context.fill(rect)

			if params.showBorder {
				drawPath(
					to: context,
					path.cgPath,
					pathWidth: Constants.borderWidth * 2
				)
			}
		} else {
			context.setFillColor(UIColor.vsGray900Color.cgColor)
			context.fill(rect)

			if params.showBorder {
				drawPath(
					to: context,
					path.cgPath,
					pathWidth: Constants.borderWidth * 2,
					color: .white
				)
			}
		}

		context.restoreGState()
	}

	private func drawCloseCross(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		var closeCrossX: CGFloat
		var closeCrossY: CGFloat

		switch params.position {
			case .top, .bottom:
				closeCrossX = rect.maxX - Constants.bubblePadding - Constants.closeCrossSize
				closeCrossY = rect.minY + Constants.closeCrossPadding

				if params.position == .bottom && params.showTip {
					closeCrossY += Constants.tipHeight
				}
			case .left:
				closeCrossX = rect.maxX
					- Constants.bubblePadding
					- Constants.closeCrossSize
				closeCrossY = Constants.bubblePadding

				if params.showTip {
					closeCrossX -= Constants.tipHeight
				}
			default:
				closeCrossX = 0
				closeCrossY = 0
		}

		let closeImage: UIImage
		if params.showInvertedStyle {
			closeImage = VirtusizeAssets.blackClose!
		} else {
			closeImage = VirtusizeAssets.whiteClose!
		}

		context.draw(
			closeImage.cgImage!,
			in: CGRect(
				x: closeCrossX,
				y: closeCrossY,
				width: Constants.closeCrossSize,
				height: Constants.closeCrossSize
			)
		)

		context.restoreGState()
	}

	private func drawTip(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		let topTipPoint: CGPoint
		let leftTipPoint: CGPoint
		let rightTipPoint: CGPoint

		var shiftX: CGFloat = 0
		var shiftY: CGFloat = 0
		switch params.position {
			case .top, .bottom:
				var startingY: CGFloat = 0
				if params.position == .top {
					startingY = rect.maxY
					shiftY = -(Constants.tipHeight + Constants.borderWidth)
				} else if params.position == .bottom {
					startingY = rect.minY
					shiftY = (Constants.tipHeight + Constants.borderWidth)
				}
				topTipPoint = CGPoint(x: rect.center.x, y: startingY)
				leftTipPoint = CGPoint(x: rect.center.x - Constants.tipWidth / 2, y: startingY + shiftY)
				rightTipPoint = CGPoint(x: rect.center.x + Constants.tipWidth / 2, y: startingY + shiftY)
			case .left:
				if params.showBorder {
					shiftX = -Constants.borderWidth
				}
				topTipPoint = CGPoint(x: rect.width - Constants.tipHeight + Constants.tipHeight, y: rect.center.y)
				leftTipPoint = CGPoint(x: rect.width - Constants.tipHeight + shiftX, y: rect.center.y - Constants.tipWidth / 2)
				rightTipPoint = CGPoint(x: rect.width - Constants.tipHeight + shiftX, y: rect.center.y + Constants.tipWidth / 2)
			default:
				topTipPoint = CGPoint()
				leftTipPoint = CGPoint()
				rightTipPoint = CGPoint()
		}

		context.beginPath()
		context.move(to: topTipPoint)
		context.addLine(to: leftTipPoint)
		context.addLine(to: rightTipPoint)
		context.closePath()

		let bottomBorderPath = UIBezierPath()
		bottomBorderPath.move(to: leftTipPoint)
		bottomBorderPath.addLine(to: rightTipPoint)
		bottomBorderPath.close()

		let leftBorderPath = UIBezierPath()
		leftBorderPath.move(to: topTipPoint)
		leftBorderPath.addLine(to: leftTipPoint)
		leftBorderPath.close()

		let rightBorderPath = UIBezierPath()
		rightBorderPath.move(to: topTipPoint)
		rightBorderPath.addLine(to: rightTipPoint)
		rightBorderPath.close()

		if params.showInvertedStyle {
			context.setFillColor(UIColor.white.cgColor)
			context.fillPath()

			if params.showBorder {
				// Overlay the line from the bubble
				drawPath(
					to: context,
					bottomBorderPath.cgPath,
					pathWidth: Constants.borderWidth * 2,
					color: .white
				)
				drawPath(to: context, leftBorderPath.cgPath)
				drawPath(to: context, rightBorderPath.cgPath)
			}
		} else {
			context.setFillColor(UIColor.vsGray900Color.cgColor)
			context.fillPath()

			if params.showBorder {
				// Overlay the line from the bubble
				drawPath(
					to: context,
					bottomBorderPath.cgPath,
					pathWidth: Constants.borderWidth * 2
				)
				drawPath(to: context, leftBorderPath.cgPath, color: .white)
				drawPath(to: context, rightBorderPath.cgPath, color: .white)
			}
		}

		context.restoreGState()
	}

	private func drawPath(
		to context: CGContext,
		_ path: CGPath,
		pathWidth: CGFloat = Constants.borderWidth,
		color: UIColor = .vsGray900Color
	) {
		context.saveGState()

		context.setStrokeColor(color.cgColor)
		context.setLineWidth(pathWidth)
		context.addPath(path)
		context.strokePath()

		context.restoreGState()
	}

	private func drawText(to context: CGContext, _ rect: CGRect) {
		context.saveGState()

		var shiftX: CGFloat = 0
		var shiftY: CGFloat = 0

		if params.showTip {
			switch params.position {
				case .bottom:
					shiftY = Constants.tipHeight
				case .left:
					break
				default:
					break
			}
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
		paragraphStyle.lineBreakMode = .byWordWrapping

		let textColor: UIColor
		if params.showInvertedStyle {
			textColor = .vsGray900Color
		} else {
			textColor = .white
		}

		let attributes = [
			NSAttributedString.Key.font: params.font,
			NSAttributedString.Key.foregroundColor: textColor,
			NSAttributedString.Key.paragraphStyle: paragraphStyle
		]

		params.text.draw(in: textRect, withAttributes: attributes)

		context.restoreGState()
	}
}
