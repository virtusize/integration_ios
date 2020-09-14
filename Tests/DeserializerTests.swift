//
//  DeserializerTests.swift
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

import Foundation
import XCTest
@testable import Virtusize

class DeserializerTests: XCTestCase {

    func testI18n_emptyData_returnI18nLocalizationWithNilProperties() {

        let actualI18nLocalization = Deserializer.i18n(data: TestFixtures.emptyResponse.data(using: .utf8))

        XCTAssertNil(actualI18nLocalization.defaultAccessoryText)
        XCTAssertNil(actualI18nLocalization.noDataText)
    }

    func testI18n_verifyEnglishLocalization_returnExpectedLocalizationTexts() {
        let data = TestUtils.shared.loadTestJsonFile(jsonFileName: "i18n_en")
        let actualI18nLocalization = Deserializer.i18n(data: data)
        let localizedLang = VirtusizeLanguage.ENGLISH

        XCTAssertEqual(
            actualI18nLocalization.defaultAccessoryText,
            Localization.shared.localize("inpage_default_accessory_text", language: localizedLang)
        )
        XCTAssertEqual(
            actualI18nLocalization.noDataText,
            Localization.shared.localize("inpage_no_data_text", language: localizedLang)
        )
    }

    func testI18n_verifyJapaneseLocalization_returnExpectedLocalizationTexts() {
        let data = TestUtils.shared.loadTestJsonFile(jsonFileName: "i18n_jp")
        let actualI18nLocalization = Deserializer.i18n(data: data)
        let localizedLang = VirtusizeLanguage.JAPANESE

         XCTAssertEqual(
            actualI18nLocalization.defaultAccessoryText,
            Localization.shared.localize("inpage_default_accessory_text", language: localizedLang)
        )
        XCTAssertEqual(
            actualI18nLocalization.noDataText,
            Localization.shared.localize("inpage_no_data_text", language: localizedLang)
        )
    }

    func testI18n_verifyKoreanLocalization_returnExpectedLocalizationTexts() {
        let data = TestUtils.shared.loadTestJsonFile(jsonFileName: "i18n_ko")
        let actualI18nLocalization = Deserializer.i18n(data: data)
        let localizedLang = VirtusizeLanguage.KOREAN

        XCTAssertEqual(
            actualI18nLocalization.defaultAccessoryText,
            Localization.shared.localize("inpage_default_accessory_text", language: localizedLang)
        )
        XCTAssertEqual(
            actualI18nLocalization.noDataText,
            Localization.shared.localize("inpage_no_data_text", language: localizedLang)
        )
    }
}
