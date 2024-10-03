//
//  VirtusizeGetSizeParamsTests.swift
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

// swiftlint:disable function_body_length type_body_length
class VirtusizeGetSizeParamsTests: XCTestCase {

    func testEncoding_hasFullGetSizeParamsData_shouldHaveExpectedDictionary() throws {
        let actualGetSizeParams = VirtusizeGetSizeParams(
            productTypes: TestFixtures.getProductTypes(),
            storeProduct: TestFixtures.getStoreProduct(gender: "female")!,
            userBodyProfile: TestFixtures.getUserBodyProfile()
        )

        let expectedGetSizeParamsData = Data(
            """
            {
                "userGender": "female",
                "userHeight": 1630,
                "userWeight": 50,
                "items": [
                    {
                        "additionalInfo": {
                            "brand": "Virtusize",
                            "fit": "regular",
                            "sizes": {
                            "35": {
                                "sleeve": 805,
                                "bust": 630,
                                "height": 740
                            },
                            "36": {
                                "sleeve": 825,
                                "bust": 645,
                                "height": 750
                            },
                            "37": {
                                "sleeve": 845,
                                "bust": 660,
                                "height": 760
                            }},
                            "gender": "female"
                        },
                        "itemSizesOrig": {
                            "35": {
                                "sleeve": 805,
                                "bust": 630,
                                "height": 740
                            },
                            "36": {
                                "sleeve": 825,
                                "bust": 645,
                                "height": 750
                            },
                            "37": {
                                "sleeve": 845,
                                "bust": 660,
                                "height": 760
                            }
                        },
                        "productType": "jacket",
                        "extProductId": "694"
                    }
                ],
                "bodyData": {
                    "neck": {
                        "value": 300,
                        "predicted": true
                    },
                    "bustWidth": {
                        "value": 245,
                        "predicted": true
                    },
                    "sleeveLength": {
                        "value": 520,
                        "predicted": true
                    },
                    "shoulderWidth": {
                        "value": 340,
                        "predicted": true
                    },
                    "waist": {
                        "value": 630,
                        "predicted": true
                    },
                    "waistHeight": {
                        "value": 920,
                        "predicted": true
                    },
                    "shoulder": {
                        "value": 370,
                        "predicted": true
                    },
                    "bicep": {
                        "value": 220,
                        "predicted": true
                    },
                    "chest": {
                        "value": 755,
                        "predicted": true
                    },
                    "shoulderHeight": {
                        "value": 1240,
                        "predicted": true
                    },
                    "waistWidth": {
                        "value": 225,
                        "predicted": true
                    },
                    "hipHeight": {
                        "value": 750,
                        "predicted": true
                    },
                    "sleeve": {
                        "value": 720,
                        "predicted": true
                    },
                    "thigh": {
                        "value": 480,
                        "predicted": true
                    },
                    "rise": {
                        "value": 215,
                        "predicted": true
                    },
                    "headHeight": {
                        "value": 215,
                        "predicted": true
                    },
                    "kneeHeight": {
                        "value": 395,
                        "predicted": true
                    },
                    "armpitHeight": {
                        "value": 1130,
                        "predicted": true
                    },
                    "hipWidth": {
                        "value": 300,
                        "predicted": true
                    },
                    "bust": {
                        "value": 755,
                        "predicted": true
                    },
                    "inseam": {
                        "value": 700,
                        "predicted": true
                    },
                    "hip": {
                        "value": 830,
                        "predicted": true
                    }
                }
            }
            """.utf8)

        guard let expectedJsonObject = try? JSONSerialization.jsonObject(
                with: expectedGetSizeParamsData, options: []
        ) else {
            XCTFail("Failed constructing an expected JsonObject from \(expectedGetSizeParamsData)")
            return
        }

        guard let actualJsonObject = try? JSONSerialization.jsonObject(
                with: JSONEncoder().encode(actualGetSizeParams), options: []
        ) else {
            XCTFail("Failed constructing an expected JsonObject from \(expectedGetSizeParamsData)")
            return
        }

        guard let expectedDict = expectedJsonObject as? NSDictionary else {
            XCTFail("Failed casting expected JSON object (i.e. \(expectedJsonObject)) to an NSDictionary")
            return
        }

        guard let actualDict = actualJsonObject as? NSDictionary else {
            XCTFail("Failed casting actual object (i.e. \(actualJsonObject)) to an NSDictionary")
            return
        }
        XCTAssertEqual(expectedDict, actualDict)
    }

    func testEncoding_hasEmptyGetSizeParamsData_shouldHaveExpectedDictionary() throws {
        let actualGetSizeParams = VirtusizeGetSizeParams(
            productTypes: [],
            storeProduct: TestFixtures.getStoreProduct(
                noSizes: true,
                brand: "",
                modelInfo: "",
                gender: nil
            )!,
            userBodyProfile: nil
        )

        let expectedGetSizeParamsData = Data(
        """
        {
            "bodyData": {},
            "items": [
                {
                    "additionalInfo": {
                        "brand": "",
                        "fit": "regular",
                        "sizes": {},
                        "gender": null
                    },
                    "itemSizesOrig": {},
                    "productType": "",
                    "extProductId": "694"
                }
            ],
            "userGender": ""
        }
""".utf8)

        guard let expectedJsonObject = try? JSONSerialization.jsonObject(
                with: expectedGetSizeParamsData, options: []
        ) else {
            XCTFail("Failed constructing an expected JsonObject from \(expectedGetSizeParamsData)")
            return
        }

        guard let actualJsonObject = try? JSONSerialization.jsonObject(
                with: JSONEncoder().encode(actualGetSizeParams), options: []
        ) else {
            XCTFail("Failed constructing an expected JsonObject from \(expectedGetSizeParamsData)")
            return
        }

        guard let expectedDict = expectedJsonObject as? NSDictionary else {
            XCTFail("Failed casting expected JSON object (i.e. \(expectedJsonObject)) to an NSDictionary")
            return
        }

        guard let actualDict = actualJsonObject as? NSDictionary else {
            XCTFail("Failed casting actual object (i.e. \(actualJsonObject)) to an NSDictionary")
            return
        }
        XCTAssertEqual(expectedDict, actualDict)
    }
}
