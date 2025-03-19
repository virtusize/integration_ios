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

#if canImport(SwiftUI)
import SwiftUI

#if (arch(arm64) || arch(x86_64))
public struct SwiftUIVirtusizeButton: UIViewRepresentable {

	private var product: VirtusizeProduct
	private var action: (() -> Void)?
	private var uiView: ((UIButton) -> Void)?
	private var virtusizeDefaultStyle: VirtusizeViewStyle?

	public init(
		product: VirtusizeProduct,
		action: (() -> Void)? = nil,
		uiView: ((UIButton) -> Void)? = nil,
		defaultStyle: VirtusizeViewStyle? = nil,
		virtusizeMessageHandler: VirtusizeMessageHandler? = nil
	) {
		self.product = product
		self.action = action
		self.uiView = uiView
		self.virtusizeDefaultStyle = defaultStyle
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	public func makeUIView(context: Context) -> VirtusizeButton {
		let virtusizeButton = VirtusizeButton()

		virtusizeButton.addTarget(
			context.coordinator,
			action: #selector(Coordinator.clickAction),
			for: .touchUpInside
		)

		context.coordinator.action = action

		self.setSwiftUIVirtusizeView(virtusizeButton, product: product)

		return virtusizeButton
	}

	public func updateUIView(_ uiView: VirtusizeButton, context: Context) {
		if let virtusizeDefaultStyle = virtusizeDefaultStyle {
			uiView.style = virtusizeDefaultStyle
		}

		self.uiView?(uiView)

		uiView.setContentHuggingPriority(.required, for: .horizontal)
		uiView.setContentHuggingPriority(.required, for: .vertical)
	}
}

extension SwiftUIVirtusizeButton {
	public class Coordinator {
		var action: (() -> Void)?

		@objc func clickAction() {
			action?()
		}
	}
}
#endif
#endif
