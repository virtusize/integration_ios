//
//  ViewController.swift
//
//  Copyright (c) 2018 Virtusize AB
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

class ViewController: UIViewController {

	@IBOutlet weak var checkTheFitButton: VirtusizeButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		checkTheFitButton.productImageURL = URL(string: "http://www.example.com/image.jpg")
		checkTheFitButton.productId = "vs_dress"

		checkTheFitButton.applyVirtusizeDesign()
	}

	@IBAction func checkTheFit() {
		let virtusize = CheckTheFitViewController(virtusizeButton: checkTheFitButton)
		virtusize.delegate = self
		present(virtusize, animated: true, completion: nil)
	}

}

extension ViewController: CheckTheFitViewControllerDelegate {
	func checkTheFitViewControllerShouldClose(_ controller: CheckTheFitViewController) {
		dismiss(animated: true, completion: nil)
	}

	func checkTheFitViewController(
        _ controller: CheckTheFitViewController,
        didReceiveEvent eventName: String,
        data: Any?) {
		switch eventName {
		case "user-opened-widget":
            return
		case "user-opened-panel-compare":
            return
		default:
            return
		}

	}

    func checkTheFitViewController(_ controller: CheckTheFitViewController, didReceiveError error: Error) {
        guard let error = error as? CheckTheFitError else {
            return
        }
        print("\(error)")
        dismiss(animated: true, completion: nil)
    }
}
