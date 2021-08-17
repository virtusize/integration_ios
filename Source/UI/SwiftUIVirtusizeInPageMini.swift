//
//  SwiftUIVirtusizeInPageMini.swift
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
import UIKit

#if (arch(arm64) || arch(x86_64))
@available(iOS 13.0, *)
public struct SwiftUIVirtusizeInPageMini: View {

	private var product: VirtusizeProduct
	private var action: (() -> Void)?
	private var uiView: ((VirtusizeInPageMini) -> Void)?
	private var virtusizeDefaultStyle: VirtusizeViewStyle?

	@State private var desiredSize: CGSize = CGSize()

	public init(
		product: VirtusizeProduct,
		action: (() -> Void)? = nil,
		uiView: ((VirtusizeInPageMini) -> Void)? = nil,
		defaultStyle: VirtusizeViewStyle? = nil
	) {
		self.product = product
		self.action = action
		self.uiView = uiView
		self.virtusizeDefaultStyle = defaultStyle
	}

	public var body: some View {
		VirtusizeInPageMiniWrapper(
			product: product,
			desiredSize: $desiredSize,
			action: action,
			uiKitView: uiView,
			defaultStyle: virtusizeDefaultStyle
		)
		.frame(width: desiredSize.width, height: max(desiredSize.height, 35), alignment: .center)
	}
}

@available(iOS 13.0, *)
private struct VirtusizeInPageMiniWrapper: UIViewRepresentable {

	private var product: VirtusizeProduct
	private var action: (() -> Void)?
	private var uiKitView: ((VirtusizeInPageMini) -> Void)?
	private var virtusizeDefaultStyle: VirtusizeViewStyle?

	@Binding var desiredSize: CGSize

	public init(
		product: VirtusizeProduct,
		desiredSize: Binding<CGSize>,
		action: (() -> Void)? = nil,
		uiKitView: ((VirtusizeInPageMini) -> Void)? = nil,
		defaultStyle: VirtusizeViewStyle? = nil
	) {
		self.product = product
		self._desiredSize = desiredSize
		self.action = action
		self.uiKitView = uiKitView
		self.virtusizeDefaultStyle = defaultStyle
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	public func makeUIView(context: Context) -> VirtusizeInPageMini {
		let virtusizeInPageMini = VirtusizeInPageMini()

		context.coordinator.action = action

		Virtusize.setSwiftUIVirtusizeView(self, virtusizeInPageMini, product: product)

		return virtusizeInPageMini
	}

	public func updateUIView(_ uiView: VirtusizeInPageMini, context: Context) {
		if let virtusizeDefaultStyle = virtusizeDefaultStyle {
			uiView.style = virtusizeDefaultStyle
		}

		// Remove UIKit specific gesture recognizers
		for recognizer in uiView.gestureRecognizers ?? [] {
			uiView.removeGestureRecognizer(recognizer)
		}
		uiView.addGestureRecognizer(
			UITapGestureRecognizer(
				target: context.coordinator,
				action: #selector(Coordinator.clickAction)
			)
		)
		uiView.inPageMiniSizeCheckButton.addTarget(
			context.coordinator,
			action: #selector(Coordinator.clickAction),
			for: .touchUpInside
		)

		if uiKitView != nil {
			uiKitView!(uiView)
		}

		uiView.setContentViewListener(listener: { view in
			if let label = (view as? VirtusizeInPageMini)?.inPageMiniMessageLabel {
				desiredSize = CGSize(
					width: UIScreen.main.bounds.size.width - uiView.userSetMargin * 2,
					height: label.text?.height(width: label.frame.width, font: label.font) ?? 35
				)
			}
		})
	}
}

@available(iOS 13.0, *)
extension VirtusizeInPageMiniWrapper {
	public class Coordinator {

		var action: (() -> Void)?

		@objc func clickAction() {
			action?()
		}
	}
}
#endif
#endif
