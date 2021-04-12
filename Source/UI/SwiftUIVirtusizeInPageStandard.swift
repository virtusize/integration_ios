//
//  SwiftUIVirtusizeInPageStandard.swift
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
public struct SwiftUIVirtusizeInPageStandard: View {

	private var action: (() -> Void)?
	private var label: ((VirtusizeInPageStandard) -> Void)?
	private var virtusizeDefaultStyle: VirtusizeViewStyle?

	@State private var desiredSize: CGSize = CGSize(width: UIScreen.main.bounds.size.width, height: 92)

	public init(
		action: (() -> Void)? = nil,
		label: ((VirtusizeInPageStandard) -> Void)? = nil,
		defaultStyle: VirtusizeViewStyle? = nil
	) {
		self.action = action
		self.label = label
		self.virtusizeDefaultStyle = defaultStyle
	}

	public var body: some View {
		VirtusizeInPageStandardWrapper(
			desiredSize: $desiredSize,
			action: action,
			label: label,
			defaultStyle: virtusizeDefaultStyle
		)
		.frame(width: desiredSize.width, height: max(desiredSize.height, 92), alignment: .center)
	}
}

@available(iOSApplicationExtension 13.0, *)
private struct VirtusizeInPageStandardWrapper: UIViewRepresentable {

	@Binding var desiredSize: CGSize

	private var action: (() -> Void)?
	private var label: ((VirtusizeInPageStandard) -> Void)?
	private var virtusizeDefaultStyle: VirtusizeViewStyle?

	public init(
		desiredSize: Binding<CGSize>,
		action: (() -> Void)? = nil,
		label: ((VirtusizeInPageStandard) -> Void)? = nil,
		defaultStyle: VirtusizeViewStyle? = nil
	) {
		self._desiredSize = desiredSize
		self.action = action
		self.label = label
		self.virtusizeDefaultStyle = defaultStyle
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	public func makeUIView(context: Context) -> VirtusizeInPageStandard {
		let virtusizeInPageStandard = VirtusizeInPageStandard()

		context.coordinator.action = action

		Virtusize.setVirtusizeView(self, virtusizeInPageStandard)

		return virtusizeInPageStandard
	}

	public func updateUIView(_ uiView: VirtusizeInPageStandard, context: Context) {
		if let virtusizeDefaultStyle = virtusizeDefaultStyle {
			uiView.style = virtusizeDefaultStyle
		}

		for recognizer in uiView.gestureRecognizers ?? [] {
			uiView.removeGestureRecognizer(recognizer)
		}
		uiView.inPageStandardView.addGestureRecognizer(
			UITapGestureRecognizer(
				target: context.coordinator,
				action: #selector(Coordinator.clickAction)
			)
		)
		uiView.checkSizeButton.addTarget(
			context.coordinator,
			action: #selector(Coordinator.clickAction),
			for: .touchUpInside
		)

		if self.label != nil {
			self.label!(uiView)
		}

		uiView.setContentViewListener(listener: { view in
			desiredSize = CGSize(
				width: UIScreen.main.bounds.size.width,
				height: view.frame.height
			)
		})
	}
}

@available(iOSApplicationExtension 13.0, *)
extension VirtusizeInPageStandardWrapper {
	public class Coordinator {

		var action: (() -> Void)?

		@objc func clickAction() {
			action?()
		}
	}
}
