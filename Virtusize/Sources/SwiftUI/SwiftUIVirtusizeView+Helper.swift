//
//  SwiftUIVirtusizeView+Helper.swift
//  Virtusize
//
//  Created by Seifer on 20.02.2025.
//  Copyright © 2025 Virtusize AB. All rights reserved.
//

import SwiftUI

extension UIViewRepresentable {
	/// Sets up the VirtusizeView for SwiftUI
	public func setSwiftUIVirtusizeView(
		_ view: VirtusizeView,
		product: VirtusizeProduct
	) {
		var mutableView = view
		mutableView.messageHandler = self as? VirtusizeMessageHandler
		mutableView.presentingViewController = self as? UIViewController
		mutableView.clientProduct = product
	}
}
