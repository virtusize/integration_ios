//
//  DesignSystemViewController.swift
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

class DesignSystemViewController: UITableViewController {
	enum DesignSystemComponent: Int, CaseIterable {
		case button
		case tooltip

		var title: String {
			switch self {
				case .button: return "Buttons"
				case .tooltip: return "Tooltips"
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Design System Example"
		tableView.tableFooterView = UIView()
		tableView.rowHeight = 60
	}

	// MARK: UITableViewDelegate

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return DesignSystemComponent.allCases.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
		if let component = DesignSystemComponent(rawValue: indexPath.row) {
			cell.textLabel?.text = component.title
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let component = DesignSystemComponent(rawValue: indexPath.row) else { return }

		if component == .button {
			let viewController = ButtonViewController()
			navigationController?.pushViewController(viewController, animated: true)
		} else if component == .tooltip {
			let viewController = TooltipViewController()
			navigationController?.pushViewController(viewController, animated: true)
		}
	}

}
