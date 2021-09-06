//
//  ButtonViewController.swift
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

class ButtonViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = "Button Example"

		let scrollView = UIScrollView(frame: view.bounds)
		view.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.backgroundColor = .white
		scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		let defaultButton = VirtusizeUIButton()
		defaultButton.setTitle("Default Button", for: .normal)
		defaultButton.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(defaultButton)

		let flatButton = VirtusizeUIButton()
		flatButton.style = .flat
		flatButton.setTitle("Flat Button", for: .normal)
		flatButton.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(flatButton)

		let invertedButton = VirtusizeUIButton()
		invertedButton.style = .inverted
		invertedButton.setTitle("Inverted Button", for: .normal)
		invertedButton.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(invertedButton)

		let disabledButton = VirtusizeUIButton()
		disabledButton.isEnabled = false
		disabledButton.setTitle("Disabled Button", for: .normal)
		disabledButton.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(disabledButton)

		let roundButton1 = VirtusizeUIRoundButton()
		roundButton1.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(roundButton1)

		let roundButton2 = VirtusizeUIRoundButton()
		roundButton2.image = VirtusizeAssets.errorHanger
		roundButton2.style = .inverted
		roundButton2.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(roundButton2)

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			defaultButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			defaultButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
			flatButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			flatButton.topAnchor.constraint(equalTo: defaultButton.bottomAnchor, constant: 16),
			invertedButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			invertedButton.topAnchor.constraint(equalTo: flatButton.bottomAnchor, constant: 16),
			disabledButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			disabledButton.topAnchor.constraint(equalTo: invertedButton.bottomAnchor, constant: 16),
			roundButton1.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			roundButton1.topAnchor.constraint(equalTo: disabledButton.bottomAnchor, constant: 16),
			roundButton2.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			roundButton2.topAnchor.constraint(equalTo: roundButton1.bottomAnchor, constant: 16)
		])
	}
}
