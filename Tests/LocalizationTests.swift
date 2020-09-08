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
            "See how everyday items fit"
        )
        XCTAssertEqual(
            Localization.shared.localize("inpage_sizing_itemBrand_large_text", language: .ENGLISH),
            "This item sizes %{boldStart}larger than the brand's average.%{boldEnd}"
        )
        XCTAssertEqual(
            Localization.shared.localize("inpage_sizing_mostBrands_true_text", language: .JAPANESE),
            "この商品は%{boldStart}平均的なサイズ感です。%{boldEnd}"
        )
        XCTAssertEqual(
            Localization.shared.localize("inpage_sizing_mostBrands_small_text", language: .KOREAN),
            "이 브랜드의 사이즈는 %{boldStart}평균보다 작습니다.%{boldEnd}"
        )
        XCTAssertEqual(
            Localization.shared.localize("inpage_fit_tight_text", language: .KOREAN),
            "이 상품은 %{boldStart}꽉 조이는 핏입니다.%{boldEnd}"
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
