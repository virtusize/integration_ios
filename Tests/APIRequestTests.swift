//
//  APIRequestTests.swift
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

class APIRequestTests: XCTestCase {

    override func setUpWithError() throws {
        Virtusize.APIKey = "test_APIKey"
        Virtusize.userID = "123"
        Virtusize.environment = .staging
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRetrieveStoreInfo_expectedHeaders() {
        let apiRequest = APIRequest.retrieveStoreInfo()

        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", BrowserID.current.identifier)
        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.get.rawValue)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://staging.virtusize.com/a/api/v3/stores/api-key/\(Virtusize.APIKey!)?format=json"
        )
    }

    func testSendOrder_expectedHeadersAndHttpBody() {
        TestFixtures.virtusizeOrder.externalUserId = Virtusize.userID
        let apiRequest = APIRequest.sendOrder(TestFixtures.virtusizeOrder)

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.post.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["Content-Type"] ?? "", "application/json")

        let orderJsonObject = try? JSONSerialization.jsonObject(
            with: apiRequest?.httpBody ?? Data(), options: []) as? JSONObject
        let orderItemJsonObject = orderJsonObject?["items"] as? [JSONObject]

        XCTAssertEqual(apiRequest?.url?.absoluteString, "https://staging.virtusize.com/a/api/v3/orders")
        XCTAssertEqual(orderJsonObject?["externalOrderId"] as? String ?? "", "4000111032")
        XCTAssertEqual(orderJsonObject?["externalUserId"] as? String ?? "", "123")
        XCTAssertEqual(orderItemJsonObject?[0]["currency"] as? String ?? "", "JPY")
    }

    func testGetStoreProductInfo_expectedHeadersAndHttpBody() {

        let apiRequest = APIRequest.getStoreProductInfo(productId: TestFixtures.productId)

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.get.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", BrowserID.current.identifier)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://staging.virtusize.com/a/api/v3/store-products/\(TestFixtures.productId)?format=json"
        )
    }

    func testGetProductTypes_expectedHeaders() {
        let apiRequest = APIRequest.getProductTypes()

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.get.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", BrowserID.current.identifier)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://staging.virtusize.com/a/api/v3/product-types"
        )
    }

    func testGetI18nTexts_expectedApiRequest() {
        let apiRequest = APIRequest.getI18n(langCode: VirtusizeLanguage.KOREAN.rawValue)

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.get.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", BrowserID.current.identifier)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://i18n.virtusize.com/bundle-payloads/aoyama/ko"
        )
    }

}
