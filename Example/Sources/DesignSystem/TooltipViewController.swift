//
//  TooltipViewController.swift
//  Example
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
import VirtusizeUIKit

class TooltipViewController: UIViewController {
	private var generalTooltip: VirtusizeUITooltip?
	private var tooltipParamsArray: [VirtusizeUITooltipParams] = []
	private var tooltipParamsArrayIndex = 0

	private var fittingRoomEntryTooltip: VirtusizeUITooltip?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = DesignSystemComponent.tooltip.title

		let showTooltipButton = VirtusizeUIButton()
		showTooltipButton.setTitle("Show Tooltip", for: .normal)
		showTooltipButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(showTooltipButton)
		showTooltipButton.addTarget(self, action: #selector(showTooltip1), for: .touchUpInside)

		let fittingRoomEntryButton = VirtusizeUIRoundButton()
		fittingRoomEntryButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(fittingRoomEntryButton)
		fittingRoomEntryButton.addTarget(self, action: #selector(showTooltip2), for: .touchUpInside)

		NSLayoutConstraint.activate([
			showTooltipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			showTooltipButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			fittingRoomEntryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			fittingRoomEntryButton.topAnchor.constraint(equalTo: showTooltipButton.bottomAnchor, constant: 16)
		])

		tooltipParamsArray.append(
			VirtusizeUITooltipParamsBuilder()
				.setAnchorView(showTooltipButton)
				.setText(text: "A tooltip appears adjacent to the element. Clicking \"Close\" will dismiss the tooltip.")
				.build()
		)

		tooltipParamsArray.append(
			VirtusizeUITooltipParamsBuilder()
				.setAnchorView(showTooltipButton)
				.setText(text: "You can set an \"invertedStyle\" prop to change the color. or \"position\" prop to change the position relative to the anchor")
				.setPosition(pos: .top)
				.invertedStyle()
				.build()
		)

		tooltipParamsArray.append(
			VirtusizeUITooltipParamsBuilder()
				.setAnchorView(showTooltipButton)
				.setText(text: "You can also set \"hideTip\" and \"hideCloseButton\" to not show each of these")
				.hideTip()
				.hideCloseButton()
				.build()
		)

		tooltipParamsArray.append(
			VirtusizeUITooltipParamsBuilder()
				.setAnchorView(showTooltipButton)
				.setText(
					text: "You can also set \"showOverlay\" prop to show a dark overlay, " +
						"and \"noBorder\" to remove the border around the carrot"
				)
				.invertedStyle()
				.showOverlay()
				.noBorder()
				.build()
		)

		fittingRoomEntryTooltip = VirtusizeUITooltip(
			params: VirtusizeUITooltipParamsBuilder()
				.setAnchorView(fittingRoomEntryButton)
				.setPosition(pos: .left)
				.hideCloseButton()
				.noBorder()
				.build()
			)
	}

	@objc private func showTooltip1() {
		generalTooltip = VirtusizeUITooltip(params: tooltipParamsArray[tooltipParamsArrayIndex])
		generalTooltip?.show()
		tooltipParamsArrayIndex += 1
		if tooltipParamsArrayIndex > tooltipParamsArray.count - 1 {
			tooltipParamsArrayIndex = 0
		}
	}

	@objc private func showTooltip2() {
		fittingRoomEntryTooltip?.show()
	}
}
