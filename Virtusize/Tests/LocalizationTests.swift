//
//  LocalizationTests.swift
//
//  Copyright (c) 2020 Virtusize KK
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

import XCTest
@testable import Virtusize

class LocalizationTests: XCTestCase {

    func testLocalization_ExistingLocalizableStrings() {
        XCTAssertEqual(
            Localization.shared.localize("inpage_default_accessory_text", language: .ENGLISH),
            "See what fits inside"
        )
		XCTAssertEqual(
			Localization.shared.localize("inpage_one_size_smaller_top_text", language: .ENGLISH),
			"This item size is"
		)
		XCTAssertEqual(
			Localization.shared.localize("inpage_one_size_smaller_bottom_text", language: .ENGLISH),
			"smaller than your item"
		)
		XCTAssertEqual(
			Localization.shared.localize("inpage_multi_size_comparison_text", language: .ENGLISH),
			"The closest size to your item is"
		)
		XCTAssertEqual(
			Localization.shared.localize("inpage_will_fit_result", language: .ENGLISH),
			"Your recommended size is"
		)
        XCTAssertEqual(
            Localization.shared.localize("inpage_no_data_text", language: .ENGLISH),
            "Find your right size"
        )
    }

    func testLocalization_NonExistingLocalizableStrings_shouldReturnKey() {
        XCTAssertEqual(
            Localization.shared.localize("inpage_accessory_text"),
            "inpage_accessory_text"
        )
        XCTAssertEqual(
            Localization.shared.localize("inpage_sizing_itembrand_large_text"),
            "inpage_sizing_itembrand_large_text"
        )
        XCTAssertEqual(
            Localization.shared.localize("inpage_sizing_mostBrands_big_text"),
            "inpage_sizing_mostBrands_big_text"
        )
    }
}
