//
//  APIEndpointsTests.swift
//
//  Copyright (c) 2020 Virtusize AB
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

class APIEndpointsTests: XCTestCase {

    private let dummyExternalId = "694"

    override func setUpWithError() throws {
        Virtusize.APIKey = "test_APIKey"
        Virtusize.userID = "123"
        Virtusize.environment = .staging
        Virtusize.language = "en"
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testProductDataCheckEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.productDataCheck(externalId: dummyExternalId)

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/integration/v3/product-data-check")

        XCTAssertEqual(endpoint.components.queryItems?.count, 3)

        let queryParamters = getQueryParametersDict(queryItems: endpoint.components.queryItems)

        XCTAssertEqual(queryParamters["apiKey"], "test_APIKey")
        XCTAssertEqual(queryParamters["externalId"], "694")
        XCTAssertNotNil(queryParamters["version"], "1")
    }

    func testProductMetaDataHintsEndpoint_withValidArguments_returnExpectedComponents() {
        Virtusize.environment = .global
        let imageUrl = URL.init(string: "https://www.testimage.com/xxx.jpg")!
        let endpoint = APIEndpoints.productMetaDataHints(
            externalId: dummyExternalId,
            imageUrl: imageUrl,
            storeId: 2
        )

        XCTAssertEqual(endpoint.components.queryItems?.count, 4)

        XCTAssertEqual(endpoint.components.host, "www.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/rest-api/v1/product-meta-data-hints")

        let queryParamters = getQueryParametersDict(queryItems: endpoint.components.queryItems)

        XCTAssertEqual(queryParamters["apiKey"], "test_APIKey")
        XCTAssertEqual(queryParamters["externalId"], "694")
        XCTAssertEqual(queryParamters["imageUrl"], "https%3A%2F%2Fwww.testimage.com%2Fxxx.jpg")
        XCTAssertEqual(queryParamters["storeId"], "2")
    }

    func testProductMetaDataHintsEndpoint_withNullStoreId_returnExpectedStoreId() {
        let imageUrl = URL.init(string: "https://www.testimage.com/xxx.jpg")!
        let endpoint = APIEndpoints.productMetaDataHints(
            externalId: dummyExternalId,
            imageUrl: imageUrl,
            storeId: nil
        )

        XCTAssertEqual(endpoint.components.queryItems?.count, 3)

        let queryParamters = getQueryParametersDict(queryItems: endpoint.components.queryItems)

        XCTAssertNil(queryParamters["storeId"])
    }

    func testEventsEndpoint_returnExpectedComponents() {
        Virtusize.environment = .korea
        let endpoint = APIEndpoints.events
        XCTAssertEqual(endpoint.components.host, "api.virtusize.kr")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/events")

        XCTAssertNil(endpoint.components.queryItems)
    }

    func testFitIllustratorEndpoint_returnExpectedComponents() {
        Virtusize.environment = .japan

        let endpoint = APIEndpoints.fitIllustrator(
            storeId: 2,
            productId: 694,
            randomNumber: 621383807
        )

        XCTAssertEqual(endpoint.components.host, "api.virtusize.jp")
        XCTAssertEqual(endpoint.components.path, "/a/fit-illustrator/v1/index.html")

        XCTAssertEqual(endpoint.components.queryItems?.count, 11)

        let queryParamters = getQueryParametersDict(queryItems: endpoint.components.queryItems)

        XCTAssertEqual(queryParamters["detached"], "false")
        XCTAssertEqual(queryParamters["bid"], BrowserID.current.identifier)
        XCTAssertEqual(queryParamters["addToCartEnabled"], "false")
        XCTAssertEqual(queryParamters["storeId"], "2")
        XCTAssertEqual(queryParamters["_"], "621383807")
        XCTAssertEqual(queryParamters["spid"], "694")
        XCTAssertEqual(queryParamters["lang"], "en")
        XCTAssertEqual(queryParamters["ios"], "true")
        XCTAssertEqual(queryParamters["sdk"], "0.2")
        XCTAssertEqual(queryParamters["userId"], "123")
        XCTAssertEqual(queryParamters["externalUserId"], "123")
    }

    func testStoreViewApiKeyEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.storeViewApiKey

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/stores/api-key/test_APIKey")

        XCTAssertEqual(endpoint.components.queryItems?.count, 1)

        let queryParamters = getQueryParametersDict(queryItems: endpoint.components.queryItems)

        XCTAssertEqual(queryParamters["format"], "json")
    }

    func testOrdersEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.orders

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/orders")

        XCTAssertNil(endpoint.components.queryItems)
    }

    private func getQueryParametersDict(queryItems: [URLQueryItem]?) -> [String: String] {
        guard let items = queryItems else {
            return [:]
        }
        return items.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }

}
