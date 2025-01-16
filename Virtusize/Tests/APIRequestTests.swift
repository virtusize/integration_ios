//
//  APIRequestTests.swift
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

class APIRequestTests: XCTestCase {

    override func setUpWithError() throws {
        Virtusize.APIKey = "test_APIKey"
        Virtusize.userID = "123"
        Virtusize.environment = .STAGING
		UserDefaultsHelper.current.accessToken = "access_token"
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVirtusizeWebView_expectedApiRequest() {
        let apiRequest = APIRequest.virtusizeWebView(version: VirtusizeConfiguration.defaultAoyamaVersion)

        XCTAssertEqual(apiRequest.httpMethod, APIMethod.get.rawValue)
        XCTAssertNil(apiRequest.httpBody)
        XCTAssertEqual(
            apiRequest.url?.absoluteString,
            "https://static.api.virtusize.com/a/aoyama/\(VirtusizeConfiguration.defaultAoyamaVersion)/sdk-webview.html"
        )
    }

    func testRetrieveStoreInfo_expectedHeaders() {
        let apiRequest = APIRequest.retrieveStoreInfo()

        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
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
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://staging.virtusize.com/a/api/v3/store-products/\(TestFixtures.productId)?format=json"
        )
    }

    func testGetUserProducts_expectedHeadersAndHttpBody() {

        let apiRequest = APIRequest.getUserProducts()

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.get.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
		XCTAssertEqual(
			apiRequest?.allHTTPHeaderFields?["Authorization"] ?? "",
			"Token \(UserDefaultsHelper.current.accessToken!)"
		)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://staging.virtusize.com/a/api/v3/user-products"
        )
    }

    func testGetProductTypes_expectedHeaders() {
        let apiRequest = APIRequest.getProductTypes()

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.get.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://staging.virtusize.com/a/api/v3/product-types"
        )
    }

    func testGetI18nTexts_expectedApiRequest() {
        let apiRequest = APIRequest.getI18n(langCode: VirtusizeLanguage.KOREAN.rawValue)

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.get.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://i18n.virtusize.com/bundle-payloads/aoyama/ko"
        )
    }

     func testGetUserBodyProfile_expectedHeadersAndHttpBody() {

        let apiRequest = APIRequest.getUserBodyProfile()

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.get.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
		XCTAssertEqual(
			apiRequest?.allHTTPHeaderFields?["Authorization"] ?? "",
			"Token \(UserDefaultsHelper.current.accessToken!)"
		)
        XCTAssertNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://staging.virtusize.com/a/api/v3/user-body-measurements"
        )
    }

    // swiftlint:disable:next function_body_length
    func testGetBodyProfileRecommendedSize_expectedHeadersAndHttpBody() {
        guard let storeProduct = TestFixtures.getStoreProduct(gender: "male") else {
            return
        }

        guard let userBodyProfile = TestFixtures.getUserBodyProfile() else {
            return
        }
        let apiRequest = APIRequest.getBodyProfileRecommendedSize(
            productTypes: TestFixtures.getProductTypes(),
            storeProduct: storeProduct,
            userBodyProfile: userBodyProfile
        )

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.post.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
        XCTAssertNotNil(apiRequest?.httpBody)
        let actualParams = try? JSONDecoder().decode(VirtusizeGetSizeParams.self, from: apiRequest!.httpBody!)
        XCTAssertNotNil(actualParams)
        XCTAssertEqual(actualParams?.items.first?.additionalInfo.count, 5)
        XCTAssertEqual(actualParams?.items.first?.additionalInfo["gender"]?.value as? String, "female")
        XCTAssertEqual(
            actualParams?.items.first?.additionalInfo["sizes"]?.value as? [String: [String: Int?]],
            ["37": [
                "sleeve": 845,
                "bust": 660,
                "height": 760
            ],
            "36": [
                "sleeve": 825,
                "bust": 645,
                "height": 750
            ],
            "35": [
                "sleeve": 805,
                "bust": 630,
                "height": 740
            ]
            ]
        )
        XCTAssertEqual(
            (actualParams?.items.first?.additionalInfo["modelInfo"]?.value as? [String: Any])?["size"] as? String,
            "38"
        )
        XCTAssertEqual(
            (actualParams?.items.first?.additionalInfo["modelInfo"]?.value as? [String: Any])?["hip"] as? Int,
            85
        )
        XCTAssertEqual(actualParams?.items.first?.additionalInfo["brand"]?.value as? String, "Virtusize")
        XCTAssertEqual(actualParams?.items.first?.additionalInfo["fit"]?.value as? String, "regular")
        XCTAssertEqual(actualParams?.bodyData.count, 22)
        XCTAssertEqual((actualParams?.bodyData["chest"])?["value"]?.value as? Int, 755)
        XCTAssertEqual(actualParams?.items.first?.itemSizesOrig.count, 3)
        XCTAssertEqual(actualParams?.items.first?.itemSizesOrig["36"]?["bust"], 645)
		XCTAssertEqual(actualParams?.userGender, "female")
		XCTAssertEqual(actualParams?.userHeight, 1630)
		XCTAssertEqual(actualParams?.userWeight, 50.00)
		XCTAssertEqual(actualParams?.items.first?.extProductId, TestFixtures.externalProductId)
        XCTAssertEqual(actualParams?.items.first?.productType, "jacket")
		XCTAssertEqual(
			apiRequest?.url?.absoluteString,
			"https://size-recommendation.virtusize.com/item"
		)
    }
}
