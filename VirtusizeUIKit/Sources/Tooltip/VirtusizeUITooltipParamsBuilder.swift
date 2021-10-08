//
//  VirtusizeUITooltipParamsBuilder.swift
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

public class VirtusizeUITooltipParamsBuilder {
	private var anchorView: UIView?
	private var text: String = "SIMILAR ITEMS"
	private var font: UIFont = VirtusizeTypography().smallBoldFont
	private var position: VirtusizeUITooltip.Position = .bottom
	private var showCloseButton: Bool = true
	private var showTip: Bool = true
	private var showInvertedStyle: Bool = false
	private var showBorder: Bool = true
	private var overlay: Bool = false

	public init() {}

	public func setAnchorView(_ value: UIView) -> VirtusizeUITooltipParamsBuilder {
		anchorView = value
		return self
	}

	public func setText(text: String) -> VirtusizeUITooltipParamsBuilder {
		self.text = text
		return self
	}

	public func setFont(font: UIFont) -> VirtusizeUITooltipParamsBuilder {
		self.font = font
		return self
	}

	public func setPosition(pos: VirtusizeUITooltip.Position) -> VirtusizeUITooltipParamsBuilder {
		position = pos
		return self
	}

	public func hideCloseButton() -> VirtusizeUITooltipParamsBuilder {
		showCloseButton = false
		return self
	}

	public func hideTip() -> VirtusizeUITooltipParamsBuilder {
		showTip = false
		return self
	}

	public func invertedStyle() -> VirtusizeUITooltipParamsBuilder {
		showInvertedStyle = true
		return self
	}

	public func noBorder() -> VirtusizeUITooltipParamsBuilder {
		showBorder = false
		return self
	}

	public func showOverlay() -> VirtusizeUITooltipParamsBuilder {
		overlay = true
		return self
	}

	public func build() -> VirtusizeUITooltipParams {
		guard let anchorView = anchorView else {
			fatalError("Please set an anchor view")
		}
		return VirtusizeUITooltipParams(
			anchorView: anchorView,
			text: text,
			font: font,
			position: position,
			showCloseButton: showCloseButton,
			showTip: showTip,
			showInvertedStyle: showInvertedStyle,
			showBorder: showBorder,
			showOverlay: overlay
		)
	}
}

public struct VirtusizeUITooltipParams {
	internal let anchorView: UIView
	internal let text: String
	internal let font: UIFont
	internal let position: VirtusizeUITooltip.Position
	internal let showCloseButton: Bool
	internal let showTip: Bool
	internal let showInvertedStyle: Bool
	internal let showBorder: Bool
	internal let showOverlay: Bool
}
