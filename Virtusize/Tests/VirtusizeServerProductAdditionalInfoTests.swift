//
//  VirtusizeServerProductAdditionalInfoTests.swift
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

// swiftlint:disable:next type_name
class VirtusizeServerProductAdditionalInfoTests: XCTestCase {

    func testDecoding_validServerProductAdditionalInfo_shouldReturnExpectedStructure() {
        let storeProductAdditionalInfo = try? JSONDecoder().decode(
            VirtusizeServerProductAdditionalInfo.self,
            from: productAdditionalInfoFixture
        )

        XCTAssertEqual(storeProductAdditionalInfo?.brand, "Virtusize")
        XCTAssertEqual(storeProductAdditionalInfo?.gender, "male")
        XCTAssertEqual(storeProductAdditionalInfo?.sizes.count, 2)
        XCTAssertEqual(storeProductAdditionalInfo?.sizes["38"]?.count, 3)
        XCTAssertEqual(storeProductAdditionalInfo?.sizes["36"]?["height"], 750)
        XCTAssertEqual(storeProductAdditionalInfo?.modelInfo?.count, 5)
        XCTAssertEqual(storeProductAdditionalInfo?.modelInfo?["size"]?.value as? String, "38")
        XCTAssertEqual(storeProductAdditionalInfo?.modelInfo?["waist"]?.value as? Int, 56)
        XCTAssertEqual(storeProductAdditionalInfo?.fit, "wide")
        XCTAssertEqual(storeProductAdditionalInfo?.brandSizing?.compare, "true")
        XCTAssertEqual(storeProductAdditionalInfo?.brandSizing?.itemBrand, true)
    }

    func testDecoding_validServerProductAdditionalInfoWithEmptySizesAndModelInfo_shouldReturnExpectedStructure() {
        let storeProductAdditionalInfo = try? JSONDecoder().decode(
            VirtusizeServerProductAdditionalInfo.self,
            from: productEmptyAdditionalInfoFixture
        )

        XCTAssertEqual(storeProductAdditionalInfo?.brand, "Virtusize")
        XCTAssertEqual(storeProductAdditionalInfo?.gender, "female")
        XCTAssertEqual(storeProductAdditionalInfo?.sizes.count, 0)
        XCTAssertEqual(storeProductAdditionalInfo?.modelInfo?.count, 0)
        XCTAssertEqual(storeProductAdditionalInfo?.fit, "loose")
        XCTAssertEqual(storeProductAdditionalInfo?.brandSizing?.compare, "small")
        XCTAssertEqual(storeProductAdditionalInfo?.brandSizing?.itemBrand, false)
    }

    func testDecoding_emptyJsonData_shouldReturnNil() {
        let storeProductAdditionalInfo = try? JSONDecoder().decode(
            VirtusizeServerProductAdditionalInfo.self,
            from: Data(TestFixtures.emptyResponse.utf8)
        )

        XCTAssertNil(storeProductAdditionalInfo)
    }

    private let productAdditionalInfoFixture = Data(
        """
            {
                "brand":"Virtusize",
                "gender":"male",
                "sizes":{
                    "38":{
                        "height":760,
                        "bust":660,
                        "sleeve":845
                    },
                    "36":{
                        "height":750,
                        "bust":645,
                        "sleeve":825
                    }
                },
                "modelInfo":{
                    "hip":85,
                    "size":"38",
                    "waist":56,
                    "bust":78,
                    "height":165
                },
                "type":"wide",
                "style":"regular",
                "fit":"wide",
                "brandSizing":{
                    "compare":"true",
                    "itemBrand":true
                }
            }
        """.utf8
    )

    private let productEmptyAdditionalInfoFixture = Data(
        """
            {
                "brand":"Virtusize",
                "gender":"female",
                "sizes":{},
                "modelInfo":{},
                "type":"loose",
                "style":"fashionable",
                "fit":"loose",
                "brandSizing":{
                    "compare":"small",
                    "itemBrand":false
                }
            }
        """.utf8
    )
}
