//
//  APIEventTests.swift
//
//  Copyright (c) 2018-present Virtusize KK
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
        XCTAssertEqual(payloadJson?["integrationVersion"], "2.12.4")
        XCTAssertEqual(payloadJson?["snippetVersion"], "2.12.4")
    }

    func testAPIEvent_alignProductCheckDataContext_hasExpectedPayload() {
        let data = TestFixtures.productCheckJsonResponse.data(using: .utf8)!
        let productCheckJsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject

        event?.align(withContext: productCheckJsonObject)

        let productCheckPayloadJson = try? JSONSerialization.jsonObject(
            with: event!.jsonPayload!, options: []) as? JSONObject

        XCTAssertEqual(productCheckPayloadJson?["storeId"] as? Int ?? -1, 2)
        XCTAssertEqual(productCheckPayloadJson?["storeName"] as? String ?? "", "virtusize")
        XCTAssertEqual(productCheckPayloadJson?["storeProductType"] as? String ?? "", "pants")
        XCTAssertEqual(productCheckPayloadJson?["storeProductExternalId"] as? String ?? "", "694")
    }

    func testAPIEvent_alignAddtionalEventData_hasExpectedPayload() {
        let data = TestFixtures.additionalEventData.data(using: .utf8)!
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
