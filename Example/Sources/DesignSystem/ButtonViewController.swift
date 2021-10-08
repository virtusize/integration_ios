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
	private let views = UIView()

	// swiftlint:disable function_body_length
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = DesignSystemComponent.button.title

		views.translatesAutoresizingMaskIntoConstraints = false

		let scrollView = UIScrollView(frame: view.bounds)
		view.addSubview(scrollView)
		scrollView.backgroundColor = .white
		scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		scrollView.contentSize = views.frame.size
		scrollView.addSubview(views)

		let defaultButton = VirtusizeUIButton()
		defaultButton.setTitle("Default Button", for: .normal)
		defaultButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(defaultButton)

		let flatButton = VirtusizeUIButton()
		flatButton.style = .flat
		flatButton.setTitle("Flat Button", for: .normal)
		flatButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(flatButton)

		let invertedButton = VirtusizeUIButton()
		invertedButton.style = .inverted
		invertedButton.setTitle("Inverted Button", for: .normal)
		invertedButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(invertedButton)

		let disabledButton = VirtusizeUIButton()
		disabledButton.isEnabled = false
		disabledButton.setTitle("Disabled Button", for: .normal)
		disabledButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(disabledButton)

		let colorButton = VirtusizeUIButton()
		colorButton.backgroundColor = UIColor.blue
		colorButton.setTitleColor(.white, for: .normal)
		colorButton.setTitle("Button", for: .normal)
		colorButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(colorButton)

		let smallButton = VirtusizeUIButton()
		smallButton.size = .small
		smallButton.setTitle("Small Button", for: .normal)
		smallButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(smallButton)

		let xxLargeButton = VirtusizeUIButton()
		xxLargeButton.size = .xxlarge
		xxLargeButton.setTitle("XXLarge Button", for: .normal)
		xxLargeButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(xxLargeButton)

		let likeButton = VirtusizeUIButton()
		likeButton.setTitle("Like", for: .normal)
		likeButton.leftImage = VirtusizeAssets.heartSolid
		likeButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(likeButton)

		let getStartedButton = VirtusizeUIButton()
		getStartedButton.setTitle("Get Started", for: .normal)
		getStartedButton.rightImage = VirtusizeAssets.rightArrow
		getStartedButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(getStartedButton)

		let fbRedirectButton = VirtusizeUIButton()
		fbRedirectButton.style = .inverted
		fbRedirectButton.setTitle("Redirect to Facebook", for: .normal)
		fbRedirectButton.leftImage = VirtusizeAssets.fbIcon
		fbRedirectButton.rightImage = VirtusizeAssets.rightArrow
		fbRedirectButton.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(fbRedirectButton)

		let roundButton1 = VirtusizeUIRoundButton()
		roundButton1.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(roundButton1)

		let roundButton2 = VirtusizeUIRoundButton()
		roundButton2.image = VirtusizeAssets.heartSolid?.tintColor(.red)
		roundButton2.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(roundButton2)

		let roundButton3 = VirtusizeUIRoundButton()
		roundButton3.image = VirtusizeAssets.lock
		roundButton3.style = .inverted
		roundButton3.translatesAutoresizingMaskIntoConstraints = false
		views.addSubview(roundButton3)

		NSLayoutConstraint.activate([
			views.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			views.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
			views.topAnchor.constraint(equalTo: scrollView.topAnchor),
			views.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			views.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			views.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			defaultButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			defaultButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
			flatButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			flatButton.topAnchor.constraint(equalTo: defaultButton.bottomAnchor, constant: 16),
			invertedButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			invertedButton.topAnchor.constraint(equalTo: flatButton.bottomAnchor, constant: 16),
			disabledButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			disabledButton.topAnchor.constraint(equalTo: invertedButton.bottomAnchor, constant: 16),
			colorButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			colorButton.topAnchor.constraint(equalTo: disabledButton.bottomAnchor, constant: 16),
			smallButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			smallButton.topAnchor.constraint(equalTo: colorButton.bottomAnchor, constant: 16),
			xxLargeButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			xxLargeButton.topAnchor.constraint(equalTo: smallButton.bottomAnchor, constant: 16),
			likeButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			likeButton.topAnchor.constraint(equalTo: xxLargeButton.bottomAnchor, constant: 16),
			getStartedButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			getStartedButton.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 16),
			fbRedirectButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			fbRedirectButton.topAnchor.constraint(equalTo: getStartedButton.bottomAnchor, constant: 16),
			roundButton1.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			roundButton1.topAnchor.constraint(equalTo: fbRedirectButton.bottomAnchor, constant: 16),
			roundButton2.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			roundButton2.topAnchor.constraint(equalTo: roundButton1.bottomAnchor, constant: 16),
			roundButton3.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			roundButton3.topAnchor.constraint(equalTo: roundButton2.bottomAnchor, constant: 16)
		])
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		views.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
	}
}
