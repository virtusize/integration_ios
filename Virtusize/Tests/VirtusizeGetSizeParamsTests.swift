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
                "userWeight": "50.00",
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
                            "style": "fashionable",
                            "item_measurements": true,
                            "fit_adjust": null
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
                            "gender": "null",
                            "style": "fashionable",
                            "item_measurements": false,
                            "fit_adjust": null
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

class VirtusizeGetSizeParamsKidTests: XCTestCase {

    func testEncoding_kidGetSizeParams_shouldUseKidPayloadKeys() throws {
        let actualGetSizeParams = VirtusizeGetSizeParamsKid(
            productTypes: TestFixtures.getProductTypes(),
            storeProduct: TestFixtures.getStoreProduct(gender: "girl")!,
            userBodyProfile: TestFixtures.getUserBodyProfile()
        )
        let json = try JSONSerialization.jsonObject(
            with: actualGetSizeParams.jsonData()!
        ) as? [String: Any]

        XCTAssertEqual(json?["ext_product_id"] as? String, TestFixtures.externalProductId)
        let product = json?["product"] as? [String: Any]
        XCTAssertEqual(product?["gender"] as? String, "girl")
        XCTAssertEqual(product?["productType"] as? String, "jacket")
        let user = json?["user"] as? [String: Any]
        XCTAssertEqual((user?["weight"] as? NSNumber)?.intValue, 50)
        XCTAssertEqual((user?["height"] as? NSNumber)?.intValue, 1630)
    }

    func testEncoding_kidGetSizeParamsFromPredictedProfile_shouldMatchWidgetPayload() throws {
        let kidBodyData = VirtusizeKidBodyData(gender: "boy", height: 1070, weight: 17, age: 5)
        let userBodyProfile = kidBodyData.bodyProfile(predictedMeasurements: [
            "ankleHeight": VirtusizeAnyCodable(50),
            "hipWidth": VirtusizeAnyCodable(195),
            "bust": VirtusizeAnyCodable(535),
            "sleeveLength": VirtusizeAnyCodable(345.0),
            "unknown": VirtusizeAnyCodable(nil as Int?)
        ])

        let actualGetSizeParams = VirtusizeGetSizeParamsKid(
            productTypes: TestFixtures.getProductTypes(),
            storeProduct: TestFixtures.getStoreProduct(gender: "kids")!,
            userBodyProfile: userBodyProfile
        )
        let json = try JSONSerialization.jsonObject(
            with: actualGetSizeParams.jsonData()!
        ) as? [String: Any]

        let product = json?["product"] as? [String: Any]
        XCTAssertEqual(product?["gender"] as? String, "kids")
        // size_measurements is additionalInfo.sizes as-is, like the web widget sends it
        let sizeMeasurements = product?["size_measurements"] as? [String: [String: Any]]
        XCTAssertEqual(Set(sizeMeasurements?.keys.map { $0 } ?? []), ["35", "36", "37"])
        XCTAssertEqual(
            sizeMeasurements?["35"] as? [String: Int],
            ["height": 740, "bust": 630, "sleeve": 805]
        )
        let user = json?["user"] as? [String: Any]
        XCTAssertEqual(user?["gender"] as? String, "boy")
        XCTAssertEqual((user?["height"] as? NSNumber)?.intValue, 1070)
        XCTAssertEqual((user?["weight"] as? NSNumber)?.intValue, 17)
        XCTAssertEqual((user?["age"] as? NSNumber)?.intValue, 5)

        // The /kid payload keeps the camelCase names returned by the predict API and adds no "chest" alias
        let bodyData = user?["bodyData"] as? [String: [String: Any]]
        XCTAssertEqual(Set(bodyData?.keys.map { $0 } ?? []), ["ankleHeight", "hipWidth", "bust", "sleeveLength"])
        XCTAssertEqual((bodyData?["hipWidth"]?["value"] as? NSNumber)?.intValue, 195)
        XCTAssertEqual((bodyData?["sleeveLength"]?["value"] as? NSNumber)?.intValue, 345)
        XCTAssertEqual(bodyData?["hipWidth"]?["predicted"] as? Bool, true)
        XCTAssertNil(bodyData?["hip_width"])
        XCTAssertNil(bodyData?["chest"])
    }

    func testKidGetSizeParams_serializesSizesInWidgetOrder() throws {
        let actualGetSizeParams = VirtusizeGetSizeParamsKid(
            productTypes: TestFixtures.getProductTypes(),
            storeProduct: TestFixtures.getStoreProduct(gender: "kids")!,
            userBodyProfile: TestFixtures.getUserBodyProfile()
        )
        let json = String(data: actualGetSizeParams.jsonData()!, encoding: .utf8)!

        // The /kid API result depends on the order of sizeNames and size_measurements keys
        XCTAssertTrue(json.contains("\"sizeNames\":[\"35\",\"36\",\"37\"]"), json)
        let sizeMeasurementsStart = json.range(of: "\"size_measurements\":")!.upperBound
        let sizeMeasurements = json[sizeMeasurementsStart...]
        let index35 = sizeMeasurements.range(of: "\"35\":")!.lowerBound
        let index36 = sizeMeasurements.range(of: "\"36\":")!.lowerBound
        let index37 = sizeMeasurements.range(of: "\"37\":")!.lowerBound
        XCTAssertTrue(index35 < index36 && index36 < index37, json)
        XCTAssertTrue(json.hasPrefix("{\"product\":{\"brand\":"), json)
        XCTAssertTrue(json.hasSuffix("\"ext_product_id\":\"\(TestFixtures.externalProductId)\"}"), json)
    }

    func testKidBodyData_intValue_parsesWidgetEventValues() {
        XCTAssertEqual(VirtusizeKidBodyData.intValue("107"), 107)
        XCTAssertEqual(VirtusizeKidBodyData.intValue(" 17 "), 17)
        XCTAssertEqual(VirtusizeKidBodyData.intValue("17.6"), 18)
        XCTAssertEqual(VirtusizeKidBodyData.intValue(5), 5)
        XCTAssertEqual(VirtusizeKidBodyData.intValue(5.0), 5)
        XCTAssertNil(VirtusizeKidBodyData.intValue("3'6\""))
        XCTAssertNil(VirtusizeKidBodyData.intValue(""))
        XCTAssertNil(VirtusizeKidBodyData.intValue(nil))
    }

    func testKidBodyData_cache_overridesOnlyReceivedValuesAndDefaultsToGirl() {
        VirtusizeKidBodyData.clearCache()
        XCTAssertNil(VirtusizeKidBodyData.cached)

        VirtusizeKidBodyData.cache(age: 5, height: 107)
        XCTAssertNil(VirtusizeKidBodyData.cached, "weight is still missing")

        VirtusizeKidBodyData.cache(weight: 17)
        XCTAssertEqual(
            VirtusizeKidBodyData.cached,
            VirtusizeKidBodyData(gender: "girl", height: 1070, weight: 17, age: 5)
        )

        VirtusizeKidBodyData.cache(gender: "boy")
        VirtusizeKidBodyData.cache(height: 110)
        XCTAssertEqual(
            VirtusizeKidBodyData.cached,
            VirtusizeKidBodyData(gender: "boy", height: 1100, weight: 17, age: 5)
        )

        VirtusizeKidBodyData.clearCache()
        XCTAssertNil(VirtusizeKidBodyData.cached)
    }
}
