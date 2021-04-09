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

import SwiftUI
import UIKit

@available(iOSApplicationExtension 13.0, *)
public struct SwiftUIVirtusizeInPageMini: View {

	private var action: (() -> Void)?
	private var label: ((VirtusizeInPageMini) -> Void)?
	private var virtusizeDefaultStyle: VirtusizeViewStyle?

	@State private var desiredHeight: CGFloat = 0

	public init(
		action: (() -> Void)? = nil,
		label: ((VirtusizeInPageMini) -> Void)? = nil,
		defaultStyle: VirtusizeViewStyle? = nil
	) {
		self.action = action
		self.label = label
		self.virtusizeDefaultStyle = defaultStyle
	}

	public var body: some View {
		VirtusizeInPageMiniWrapper(
			desiredHeight: $desiredHeight,
			action: action,
			label: label,
			defaultStyle: virtusizeDefaultStyle
		)
		.frame(height: max(desiredHeight, 35), alignment: .center)
	}
}

@available(iOSApplicationExtension 13.0, *)
private struct VirtusizeInPageMiniWrapper: UIViewRepresentable {

	private var action: (() -> Void)?
	private var label: ((VirtusizeInPageMini) -> Void)?
	private var virtusizeDefaultStyle: VirtusizeViewStyle?

	@Binding var desiredHeight: CGFloat

	public init(
		desiredHeight: Binding<CGFloat>,
		action: (() -> Void)? = nil,
		label: ((VirtusizeInPageMini) -> Void)? = nil,
		defaultStyle: VirtusizeViewStyle? = nil
	) {
		self._desiredHeight = desiredHeight
		self.action = action
		self.label = label
		self.virtusizeDefaultStyle = defaultStyle
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	public func makeUIView(context: Context) -> VirtusizeInPageMini {
		let virtusizeInPageMini = VirtusizeInPageMini()

		context.coordinator.action = action

		Virtusize.setVirtusizeView(self, virtusizeInPageMini)

		return virtusizeInPageMini
	}

	public func updateUIView(_ uiView: VirtusizeInPageMini, context: Context) {
		if let virtusizeDefaultStyle = virtusizeDefaultStyle {
			uiView.style = virtusizeDefaultStyle
		}

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

		if self.label != nil {
			self.label!(uiView)
		}

		uiView.setMessageLabelListener(listener: { label in
			desiredHeight = label.text?.height(withConstrainedWidth: label.frame.width, font: label.font) ?? 35
		})
	}
}

@available(iOSApplicationExtension 13.0, *)
extension VirtusizeInPageMiniWrapper {
	public class Coordinator {

		var action: (() -> Void)?

		@objc func callAction() {
			action?()
		}
	}
}