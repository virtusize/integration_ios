//
//  SwiftUIVirtusizeButton.swift
//
//  Copyright (c) 2021-present Virtusize KK
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

import SwiftUI

@available(iOSApplicationExtension 13.0, *)
public struct SwiftUIVirtusizeButton: UIViewRepresentable {

	private var action: (() -> Void)?
	private var label: ((UIButton) -> Void)?
	private var storeProduct: VirtusizeProduct
	private var virtusizeDefaultStyle: VirtusizeViewStyle?
	private var virtusizeMessageHandler: VirtusizeMessageHandler?

	public init(
		action: (() -> Void)? = nil,
		label: ((UIButton) -> Void)? = nil,
		storeProduct: VirtusizeProduct,
		defaultStyle: VirtusizeViewStyle? = nil,
		virtusizeMessageHandler: VirtusizeMessageHandler? = nil) {
		self.action = action
		self.label = label
		self.storeProduct = storeProduct
		self.virtusizeDefaultStyle = defaultStyle
		self.virtusizeMessageHandler = virtusizeMessageHandler
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	public func makeUIView(context: Context) -> VirtusizeButton {
		let virtusizeButton = VirtusizeButton()

		virtusizeButton.addTarget(
			context.coordinator,
			action: #selector(Coordinator.callAction),
			for: .touchUpInside
		)

		if let virtusizeDefaultStyle = virtusizeDefaultStyle {
			virtusizeButton.applyDefaultStyle(virtusizeDefaultStyle)
		}

		if label != nil {
			label!(virtusizeButton)
		}

		virtusizeButton.setContentHuggingPriority(.required, for: .horizontal)
		virtusizeButton.setContentHuggingPriority(.required, for: .vertical)

		return virtusizeButton
	}

	public func updateUIView(_ uiView: VirtusizeButton, context: Context) {
		uiView.storeProduct = storeProduct
		context.coordinator.action = action
	}
}

@available(iOSApplicationExtension 13.0, *)
extension SwiftUIVirtusizeButton {
	public class Coordinator {
		var action: (() -> Void)?

		@objc func callAction() {
			action?()
		}
	}
}
