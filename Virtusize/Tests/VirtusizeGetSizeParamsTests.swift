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

class VirtusizeGetSizeParamsTests: XCTestCase {

	// swiftlint:disable:next function_body_length
    func testEncoding_hasFullGetSizeParamsData_shouldHaveExpectedDictionary() throws {
        let actualGetSizeParams = VirtusizeGetSizeParams(
            productTypes: TestFixtures.getProductTypes(),
            storeProduct: TestFixtures.getStoreProduct(gender: "female")!,
            userBodyProfile: TestFixtures.getUserBodyProfile()
        )

        let expectedGetSizeParamsData = Data(
            """
            {
                "appOrigin": 2,
                "userGender": "female",
                "userHeight": 1630,
                "userWeight": 50,
                "userAge": 32,
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
                                }
                            },
                            "gender": "female",
                            "modelInfo": {
                                "hip": 85,
                                "size": "38",
                                "bust": 78,
                                "waist": 56,
                                "height": 165
                            },
                            "style": "fashionable"
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
                    "bust_width": {
                        "value": 245,
                        "predicted": true
                    },
                    "sleeve_length": {
                        "value": 520,
                        "predicted": true
                    },
                    "shoulder_width": {
                        "value": 340,
                        "predicted": true
                    },
                    "waist": {
                        "value": 630,
                        "predicted": true
                    },
                    "waist_height": {
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
                    "shoulder_height": {
                        "value": 1240,
                        "predicted": true
                    },
                    "waist_width": {
                        "value": 225,
                        "predicted": true
                    },
                    "hip_height": {
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
                    "head_height": {
                        "value": 215,
                        "predicted": true
                    },
                    "knee_height": {
                        "value": 395,
                        "predicted": true
                    },
                    "armpit_height": {
                        "value": 1130,
                        "predicted": true
                    },
                    "hip_width": {
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

	// swiftlint:disable:next function_body_length
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
                "appOrigin": 2,
                "bodyData": {},
                "items": [
                    {
                        "additionalInfo": {
                            "brand": "",
                            "fit": "regular",
                            "sizes": {},
                            "modelInfo": null,
                            "gender": "null",
                            "style": "fashionable"
                        },
                        "itemSizesOrig": {},
                        "productType": "",
                        "extProductId": "694"
                    }
                ],
                "userGender": ""
            }
            """.utf8
        )

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
