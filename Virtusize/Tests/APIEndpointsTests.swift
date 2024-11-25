//
//  APIEndpointsTests.swift
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

class APIEndpointsTests: XCTestCase {

    private let dummyExternalId = "694"

    override func setUpWithError() throws {
        Virtusize.APIKey = "test_APIKey"
        Virtusize.userID = "123"
        Virtusize.environment = .STAGING
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testProductCheckEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.productCheck(externalId: dummyExternalId)

        XCTAssertEqual(endpoint.components.host, "services.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/stg/product/check")

        XCTAssertEqual(endpoint.components.queryItems?.count, 3)

        let queryParameters = getQueryParametersDict(queryItems: endpoint.components.queryItems)

        XCTAssertEqual(queryParameters["apiKey"], "test_APIKey")
        XCTAssertEqual(queryParameters["externalId"], "694")
        XCTAssertNotNil(queryParameters["version"], "1")
    }

    func testProductMetaDataHintsEndpoint_returnExpectedComponents() {
        Virtusize.environment = .GLOBAL
        let endpoint = APIEndpoints.productMetaDataHints

        XCTAssertEqual(endpoint.components.host, "api.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/rest-api/v1/product-meta-data-hints")

        XCTAssertNil(endpoint.components.queryItems)
    }

    func testEventsEndpoint_returnExpectedComponents() {
        Virtusize.environment = .KOREA
        let endpoint = APIEndpoints.events
        XCTAssertEqual(endpoint.components.host, "events.virtusize.kr")
        XCTAssertEqual(endpoint.components.path, "")

        XCTAssertNil(endpoint.components.queryItems)
    }

    func testLatestAoyamaVersionEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.latestAoyamaVersion

        XCTAssertEqual(endpoint.components.host, "static.api.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/aoyama/latest.txt")
    }

    func testVirtusizeWebViewEndpoint_japanEnv_returnExpectedComponents() {
        Virtusize.environment = .JAPAN

        let endpoint = APIEndpoints.virtusizeWebView(version: VirtusizeConfiguration.defaultAoyamaVersion)

        XCTAssertEqual(endpoint.components.host, "static.api.virtusize.jp")

		XCTAssertEqual(endpoint.components.path, "/a/aoyama/\(VirtusizeConfiguration.defaultAoyamaVersion)/sdk-webview.html")

        XCTAssertNil(endpoint.components.queryItems)
    }

	func testVirtusizeWebViewEndpoint_stagingEnv_returnExpectedComponents() {
		Virtusize.environment = .STAGING

		let endpoint = APIEndpoints.virtusizeWebView(version: VirtusizeConfiguration.defaultAoyamaVersion)

		XCTAssertEqual(endpoint.components.host, "static.api.virtusize.com")
		XCTAssertEqual(endpoint.components.path, "/a/aoyama/\(VirtusizeConfiguration.defaultAoyamaVersion)/sdk-webview.html")

		XCTAssertNil(endpoint.components.queryItems)
	}

    func testStoreViewApiKeyEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.storeViewApiKey

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/stores/api-key/test_APIKey")

        XCTAssertEqual(endpoint.components.queryItems?.count, 1)

        let queryParameters = getQueryParametersDict(queryItems: endpoint.components.queryItems)

        XCTAssertEqual(queryParameters["format"], "json")
    }

    func testOrdersEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.orders

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/orders")

        XCTAssertNil(endpoint.components.queryItems)
    }

    func testStoreProductsEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.storeProducts(productId: 7110384)

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/store-products/7110384")

        XCTAssertEqual(endpoint.components.queryItems?.count, 1)

        let queryParameters = getQueryParametersDict(queryItems: endpoint.components.queryItems)

        XCTAssertEqual(queryParameters["format"], "json")
    }

    func testUserProductsEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.userProducts

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/user-products")

        XCTAssertNil(endpoint.components.queryItems)
    }

    func testProductTypesEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.productTypes

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/product-types")

        XCTAssertNil(endpoint.components.queryItems)
    }

    func testI18nEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.i18n(langCode: VirtusizeLanguage.JAPANESE.rawValue)

        XCTAssertEqual(endpoint.components.host, "i18n.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/bundle-payloads/aoyama/ja")

        XCTAssertNil(endpoint.components.queryItems)
    }

    func testUserBodyMeasurementsEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.userBodyMeasurements

        XCTAssertEqual(endpoint.components.host, "staging.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/a/api/v3/user-body-measurements")

        XCTAssertNil(endpoint.components.queryItems)
    }

    func testGetSizeEndpoint_returnExpectedComponents() {
        let endpoint = APIEndpoints.getSize

        XCTAssertEqual(endpoint.components.host, "size-recommendation.virtusize.com")
        XCTAssertEqual(endpoint.components.path, "/item")

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
