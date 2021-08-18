//
//  VirtusizeProductSizeTests.swift
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

class VirtusizeProductSizeTests: XCTestCase {

    func testDecoding_validProductSizeData_shouldReturnExpectedStructure() {
        let productSize = try? JSONDecoder().decode(VirtusizeProductSize.self, from: productSizeFixture)

        XCTAssertEqual(productSize?.name, " ")
        XCTAssertEqual(productSize?.measurements, ["width": 150, "depth": 100, "height": 160])
    }

    func testDecoding_productSizeDataWithNullInfo_shouldReturnExpectedStructure() {
        let productSize = try? JSONDecoder().decode(VirtusizeProductSize.self, from: productSizeWithNullInfoFixture)

        XCTAssertEqual(productSize?.name, "")
        XCTAssertEqual(
            productSize?.measurements, [
                "height": 560,
                "bust": 450,
                "sleeve": 730
            ]
        )
    }

    func testDecoding_emptyJsonData_shouldReturnNil() {
        let productSize = try? JSONDecoder().decode(
            VirtusizeProductSize.self,
            from: Data(TestFixtures.emptyResponse.utf8)
        )

        XCTAssertNil(productSize)
    }

    private let productSizeFixture = Data(
        """
            {
                "name": " ",
                "measurements": {
                    "width": 150,
                    "depth": 100,
                    "height": 160
                }
            }
        """.utf8
    )

    private let productSizeWithNullInfoFixture = Data(
        """
            {
                "name": "",
                "measurements": {
                    "height": 560,
                    "bust": 450,
                    "sleeve": 730,
                    "shoulder": null,
                    "waist": null,
                    "hem": null,
                    "bicep": null
                }
            }
        """.utf8
    )
}
