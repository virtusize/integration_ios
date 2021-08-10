//
//  ProductViewController.swift
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

import UIKit
import Virtusize

class ProductViewController: UIViewController {
	let externalIDList = [
		"vs_dress",
		"vs_top",
		 "vs_shirt",
		 "vs_coat",
		 "vs_jacket",
		 "vs_sweater",
		 "vs_skirt",
		 "vs_pants"
	]
	public convenience init() {
		self.init(nibName: nil, bundle: nil)
	}

	// swiftlint:disable function_body_length
	override func viewDidLoad() {
		super.viewDidLoad()

		let randomExternalID = externalIDList.randomElement()!
		self.navigationItem.title = "Virtusize Product \(randomExternalID)"

		let product = VirtusizeProduct(
			externalId: randomExternalID,
			imageURL: URL(string: "http://www.example.com/image.jpg")
		)

		let checkTheFitButton = VirtusizeButton()
		view.addSubview(checkTheFitButton)
		checkTheFitButton.translatesAutoresizingMaskIntoConstraints = false
		checkTheFitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
		checkTheFitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true

		checkTheFitButton.bindVirtusize(self, product: product)
		checkTheFitButton.style = .TEAL

		let inPageStandard = VirtusizeInPageStandard()
		view.addSubview(inPageStandard)
		Virtusize.setVirtusizeView(self, inPageStandard)
		// You can set the horizontal margins by using `setHorizontalMargin`
		inPageStandard.setHorizontalMargin(view: view, margin: 16)
		// You can set the Virtusize InPage Standard style
		inPageStandard.style = .BLACK
		// You can set the background color of the size check button
		inPageStandard.inPageStandardButtonBackgroundColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
		// You can set the font sizes for the InPage texts
		inPageStandard.buttonFontSize = 12
		inPageStandard.messageFontSize = 12
		// Set up constraints if needed
		inPageStandard.translatesAutoresizingMaskIntoConstraints = false
		inPageStandard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		inPageStandard.topAnchor.constraint(equalTo: checkTheFitButton.bottomAnchor, constant: 16).isActive = true

		let inPageMini = VirtusizeInPageMini()
		view.addSubview(inPageMini)
		Virtusize.setVirtusizeView(self, inPageMini)
		inPageMini.inPageMiniBackgroundColor = #colorLiteral(red: 0.262745098, green: 0.5960784314, blue: 0.9882352941, alpha: 1)
		// You can set the horizontal margins by using `setHorizontalMargin`
		inPageMini.setHorizontalMargin(view: view, margin: 16)
		// You can set the font sizes for the InPage Mini texts
		inPageMini.messageFontSize = 12
		inPageMini.buttonFontSize = 10
		// Set up constraints if needed
		inPageMini.translatesAutoresizingMaskIntoConstraints = false
		inPageMini.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		inPageMini.topAnchor.constraint(equalTo: inPageStandard.bottomAnchor, constant: 16).isActive = true

		Virtusize.loadVirtusize(product: product)

		let nextProductButton = UIButton()
		view.addSubview(nextProductButton)
		nextProductButton.translatesAutoresizingMaskIntoConstraints = false
		nextProductButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nextProductButton.topAnchor.constraint(equalTo: inPageMini.bottomAnchor, constant: 16).isActive = true
		nextProductButton.backgroundColor = UIColor.black
		nextProductButton.setTitle("Go to next product page", for: .normal)
		nextProductButton.addTarget(self, action: #selector(goToNextProduct), for: .touchUpInside)
	}

	@objc func goToNextProduct() {
		let nextView = self.storyboard?.instantiateViewController(
			withIdentifier: "ProductViewController"
		) as? ProductViewController
		self.navigationController?.pushViewController(
			nextView!,
			animated: true
		)
	}
}
