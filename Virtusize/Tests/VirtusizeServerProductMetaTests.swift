//
//  VirtusizeServerProductMetaTests.swift
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

class VirtusizeServerProductMetaTests: XCTestCase {

    func testDecoding_validStoreProductMetaData_shouldReturnExpectedStructure() {
        let storeProductMeta = try? JSONDecoder().decode(VirtusizeServerProductMeta.self, from: storeProductMetaFixture)

        XCTAssertEqual(storeProductMeta?.id, 123)
        XCTAssertEqual(storeProductMeta?.additionalInfo?.fit, "loose")
        XCTAssertEqual(storeProductMeta?.additionalInfo?.brandSizing?.compare, "small")
        XCTAssertEqual(storeProductMeta?.additionalInfo?.brandSizing?.itemBrand, true)
        XCTAssertEqual(storeProductMeta?.brand, "Virtusize")
        XCTAssertEqual(storeProductMeta?.gender, "female")
    }

    func testDecoding_emptyJsonData_shouldReturnNil() {
        let storeProductMeta = try? JSONDecoder().decode(
            VirtusizeServerProductMeta.self,
            from: Data(TestFixtures.emptyResponse.utf8)
        )

        XCTAssertNil(storeProductMeta)
    }

    private let storeProductMetaFixture = Data(
        """
            {
                "id":123,
                "modelInfo":null,
                "materials":{
                    "main":{
                        "cotton":1.0
                    }
                },
                "matAnalysis":null,
                "additionalInfo":{
                    "brand":"Virtusize",
                    "gender":"female",
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
                    "type":"loose",
                    "style":"fashionable",
                    "fit":"loose",
                    "brandSizing":{
                        "compare":"small",
                        "itemBrand":true
                    }
                },
                "price":{},
                "salePrice":{},
                "availableSizes":[],
                "attributes":{
                    "defaults":false,
                    "topsFit":"loose"
                },
                "created":"2020-04-24T22:17:13Z",
                "updated":"2020-05-30T21:20:39Z",
                "brand":"Virtusize",
                "active":true,
                "url":"",
                "gender":"female",
                "color":null,
                "style":null,
                "storeProduct":12345
            }
        """.utf8
    )
}
