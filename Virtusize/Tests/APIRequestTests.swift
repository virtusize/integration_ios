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
            "https://services.virtusize.com/stg/a/api/v3/store-products/\(TestFixtures.productId)?format=json"
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
            "https://services.virtusize.com/stg/a/api/v3/product-types"
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
            "https://staging.virtusize.com/a/api/v3/user-body-measurements/"
        )
    }

    func testPredictUserBodyMeasurements_expectedHeadersAndHttpBody() throws {
        let kidBodyProfile = VirtusizeKidBodyProfile(
            gender: "boy",
            age: 5,
            height: 1070,
            weight: "17"
        )

        let apiRequest = APIRequest.predictUserBodyMeasurements(kidBodyProfile: kidBodyProfile)

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.post.rawValue)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["Content-Type"] ?? "", "application/json")
        XCTAssertEqual(
            apiRequest?.allHTTPHeaderFields?["Authorization"] ?? "",
            "Token \(UserDefaultsHelper.current.accessToken!)"
        )
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://staging.virtusize.com/a/api/v3/user-body-measurements-predict"
        )

        let json = try JSONSerialization.jsonObject(with: apiRequest!.httpBody!) as? [String: Any]
        XCTAssertEqual(json?["gender"] as? String, "boy")
        XCTAssertEqual((json?["height"] as? NSNumber)?.intValue, 1070)
        XCTAssertEqual((json?["weight"] as? NSNumber)?.intValue, 17)
        XCTAssertEqual((json?["age"] as? NSNumber)?.intValue, 5)
        XCTAssertEqual(json?.count, 4)
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
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let actualParams = try? decoder.decode(VirtusizeGetSizeParams.self, from: apiRequest!.httpBody!)
        XCTAssertNotNil(actualParams)
        XCTAssertEqual(actualParams?.items.first?.additionalInfo.count, 8)
        XCTAssertEqual(actualParams?.items.first?.additionalInfo["item_measurements"]?.value as? Bool, true)
        XCTAssertEqual(actualParams?.items.first?.additionalInfo["gender"]?.value as? String, "male")
        let sizeOrder = (actualParams?.items.first?.additionalInfo["client_size_order"]?.value as? [Any])?
            .compactMap { $0 as? String }
        XCTAssertEqual(sizeOrder, ["35", "36", "37"])
        let sizes = actualParams?.items.first?.additionalInfo["sizes"]?.value as? [String: Any]
        XCTAssertEqual((sizes?["37"] as? [String: Any])?["sleeve"] as? Int, 845)
        XCTAssertEqual((sizes?["37"] as? [String: Any])?["bust"] as? Int, 660)
        XCTAssertEqual((sizes?["36"] as? [String: Any])?["height"] as? Int, 750)
        XCTAssertEqual((sizes?["35"] as? [String: Any])?["bust"] as? Int, 630)
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
        XCTAssertEqual(actualParams?.bodyData.count, 25)
        XCTAssertEqual((actualParams?.bodyData["chest"])?["value"]?.value as? Int, 760)
        XCTAssertEqual((actualParams?.bodyData["bust"])?["value"]?.value as? Int, 755)
        XCTAssertEqual((actualParams?.bodyData["bra_country"])?["value"]?.value as? String, "")
        XCTAssertEqual((actualParams?.bodyData["bra_band"])?["value"]?.value as? Int, 0)
        XCTAssertEqual((actualParams?.bodyData["bra_band"])?["predicted"]?.value as? Bool, false)
        XCTAssertEqual(actualParams?.items.first?.itemSizesOrig.count, 3)
        XCTAssertEqual(actualParams?.items.first?.itemSizesOrig["36"]?["bust"], 645)
		XCTAssertEqual(actualParams?.userGender, "female")
		XCTAssertEqual(actualParams?.userHeight, 1630)
		XCTAssertEqual(actualParams?.userWeight, 50.0)
        XCTAssertNil(actualParams?.items.first?.fitAdjust)
		XCTAssertEqual(actualParams?.items.first?.extProductId, TestFixtures.externalProductId)
        XCTAssertEqual(actualParams?.items.first?.productType, "jacket")
		XCTAssertEqual(
			apiRequest?.url?.absoluteString,
			"https://size-recommendation.staging.virtusize.jp/item"
		)
        let payload = String(data: apiRequest!.httpBody!, encoding: .utf8) ?? ""
        XCTAssertTrue(payload.contains("\"item_sizes_orig\":{\"35\":"))
        XCTAssertTrue(payload.contains("\"sizes\":{\"35\":"))
        assertSizeKeysInOrder(payload, objectKey: "item_sizes_orig")
        assertSizeKeysInOrder(payload, objectKey: "sizes")
    }

    func testGetBodyProfileRecommendedKidSize_expectedHeadersAndHttpBody() throws {
        guard let storeProduct = TestFixtures.getStoreProduct(gender: "girl") else {
            return
        }

        guard let userBodyProfile = TestFixtures.getUserBodyProfile() else {
            return
        }
        let apiRequest = APIRequest.getBodyProfileRecommendedKidSize(
            productTypes: TestFixtures.getProductTypes(),
            storeProduct: storeProduct,
            userBodyProfile: userBodyProfile
        )

        XCTAssertEqual(apiRequest?.httpMethod, APIMethod.post.rawValue)
        XCTAssertNotNil(apiRequest?.httpBody)
        XCTAssertEqual(
            apiRequest?.url?.absoluteString,
            "https://size-recommendation.staging.virtusize.jp/kid"
        )
        // Same headers as the web widget
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["Content-Type"] ?? "", "application/json")
        XCTAssertEqual(apiRequest?.allHTTPHeaderFields?["x-vs-bid"] ?? "", UserDefaultsHelper.current.identifier)
        XCTAssertEqual(
            apiRequest?.allHTTPHeaderFields?["Authorization"] ?? "",
            "Token \(UserDefaultsHelper.current.accessToken!)"
        )

        let json = try JSONSerialization.jsonObject(with: apiRequest!.httpBody!) as? [String: Any]
        XCTAssertEqual(json?["ext_product_id"] as? String, TestFixtures.externalProductId)
        let product = json?["product"] as? [String: Any]
        XCTAssertEqual(product?["gender"] as? String, "girl")
        XCTAssertEqual(product?["brand"] as? String, "Virtusize")
        XCTAssertEqual(product?["productType"] as? String, "jacket")
        XCTAssertNotNil(product?["sizeNames"] as? [String])
        XCTAssertNotNil(product?["size_measurements"] as? [String: Any])
        let user = json?["user"] as? [String: Any]
        XCTAssertEqual(user?["gender"] as? String, "female")
        XCTAssertEqual((user?["height"] as? NSNumber)?.intValue, 1630)
        XCTAssertEqual((user?["weight"] as? NSNumber)?.intValue, 50)
        XCTAssertEqual((user?["age"] as? NSNumber)?.intValue, 32)
        XCTAssertNotNil(user?["bodyData"] as? [String: Any])
    }
}

/// `35`, `36`, and `37` must appear in that order inside the size object. The size API walks that order.
private func assertSizeKeysInOrder(_ payload: String, objectKey: String) {
    guard let start = payload.range(of: "\"\(objectKey)\":{") else {
        XCTFail("Missing \(objectKey)")
        return
    }
    let object = payload[start.upperBound...]
    guard let index36 = object.range(of: "\"36\":")?.lowerBound,
          let index37 = object.range(of: "\"37\":")?.lowerBound else {
        XCTFail("Missing size keys in \(objectKey)")
        return
    }
    XCTAssertLessThan(index36, index37)
}
