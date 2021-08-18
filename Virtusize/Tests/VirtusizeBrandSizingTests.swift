//
//  VirtusizeBrandSizingTests.swift
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

class VirtusizeBrandSizingTests: XCTestCase {

    func testDecoding_validBrandSizingData_shouldReturnExpectedStructure() {
        let brandSizing = try? JSONDecoder().decode(VirtusizeBrandSizing.self, from: brandSizingFixture)

        XCTAssertEqual(brandSizing?.compare, "small")
        XCTAssertEqual(brandSizing?.itemBrand, false)
    }

    func testDecoding_emptyJsonData_shouldReturnNil() {
        let brandSizing = try? JSONDecoder().decode(
            VirtusizeBrandSizing.self,
            from: Data(TestFixtures.emptyResponse.utf8)
        )

        XCTAssertNil(brandSizing)
    }

    private let brandSizingFixture = Data(
        """
            {
                "compare":"small",
                "itemBrand":false
            }
        """.utf8
    )
}
