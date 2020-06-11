//
//  APIEventTests.swift
//  VirtusizeTests
//
//  Created by Kuei-Jung Hu on 2020/06/11.
//  Copyright © 2020 Virtusize AB. All rights reserved.
//

import XCTest
@testable import Virtusize

class APIEventTests: XCTestCase {

    private var event: APIEvent?

    override func setUpWithError() throws {
        event = APIEvent(withName: "eventName", apiKey: "testApiKey")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitAPIEvent_hasExpectedPayload() throws {
        XCTAssertEqual(event?.name, "eventName")

        let payloadJson = try? JSONSerialization.jsonObject(with: event!.jsonPayload!, options: []) as? [String: String]
        let screenSize = UIScreen.main.bounds.size

        XCTAssertEqual(payloadJson?["name"], "eventName")
        XCTAssertEqual(payloadJson?["apiKey"], "testApiKey")
        XCTAssertEqual(payloadJson?["type"], "user")
        XCTAssertEqual(payloadJson?["source"], "integration-ios")
        XCTAssertEqual(payloadJson?["userCohort"], "direct")
        XCTAssertEqual(payloadJson?["widgetType"], "mobile")
        XCTAssertEqual(payloadJson?["browserOrientation"],
                       UIDevice.current.orientation.isLandscape ? "landscape" : "portrait"
        )
        XCTAssertEqual(payloadJson?["browserResolution"], "\(Int(screenSize.height))x\(Int(screenSize.width))")
        XCTAssertEqual(payloadJson?["integrationVersion"], "0.2")
        XCTAssertEqual(payloadJson?["snippetVersion"], "0.2")
    }

    func testAPIEventAlighProductDataCheckContext_hasExpectedPayload() {
        let data = TestEvironment.productDataCheckJsonString.data(using: .utf8)!
        let productDataCheckJsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject

        event?.align(withContext: productDataCheckJsonObject)

        let productDataCheckPayloadJson = try? JSONSerialization.jsonObject(
            with: event!.jsonPayload!, options: []) as? JSONObject

        XCTAssertEqual(productDataCheckPayloadJson?["storeId"] as? Int ?? -1, 2)
        XCTAssertEqual(productDataCheckPayloadJson?["storeName"] as? String ?? "", "virtusize")
        XCTAssertEqual(productDataCheckPayloadJson?["storeProductType"] as? String ?? "", "pants")
        XCTAssertEqual(productDataCheckPayloadJson?["storeProductExternalId"] as? String ?? "", "694")
        XCTAssertEqual(productDataCheckPayloadJson?["wardrobeActive"] as? Bool ?? false, true)
        XCTAssertNil(productDataCheckPayloadJson?["wardrobeHasM"])
        XCTAssertNil(productDataCheckPayloadJson?["wardrobeHasP"])
        XCTAssertNil(productDataCheckPayloadJson?["wardrobeHasR"])
    }

    func testAPIEventAlighAddtionalEventData_hasExpectedPayload() {
        let data = TestEvironment.additionalEventData.data(using: .utf8)!
        let addtionalEventDataJsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject

        event?.align(withPayload: addtionalEventDataJsonObject)

        let addtionalEventPayloadJson = try? JSONSerialization.jsonObject(
            with: event!.jsonPayload!, options: []) as? JSONObject

        XCTAssertEqual(addtionalEventPayloadJson?["cloudinaryPublicId"] as? String ?? "", "testCloudinaryPublicId")
        XCTAssertEqual(addtionalEventPayloadJson?["productTypeId"] as? Int ?? -1, 5)
        XCTAssertEqual(addtionalEventPayloadJson?["size"] as? String ?? "", "medium")
        XCTAssertEqual(addtionalEventPayloadJson?["wardrobeBoughtItem"] as? Int ?? -1, 3)
    }
}

struct TestEvironment {
    static var productDataCheckJsonString =
    """
        {
            "data":{
                "productTypeName": "pants",
                "storeName": "virtusize",
                "storeId": 2,
                "validProduct": true,
                "fetchMetaData": false,
                "productDataId": 7110384,
                "productTypeId": 5,
                "userData": {
                        "should_see_ph_tooltip": false,
                        "wardrobeActive": true
                    }
            },
            "name": "backend-checked-product",
            "productId": "694"
        }
    """

    static var additionalEventData =
    """
        {
            "cloudinaryPublicId": "testCloudinaryPublicId",
            "productTypeId": 5,
            "size": "medium",
            "wardrobeBoughtItem": 3
        }
    """
}
