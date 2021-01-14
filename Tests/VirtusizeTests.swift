//
//  VirtusizeTests.swift
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

class VirtusizeTests: XCTestCase {

    override func setUpWithError() throws {
        Virtusize.APIKey = TestFixtures.apiKey
        Virtusize.userID = "123"
        Virtusize.environment = .staging
    }

    func testProductDataCheck_hasExpectedCallbackData() {
        let expectation = self.expectation(description: "Virtusize.productCheck reaches the callback")
        var acutalProduct: VirtusizeProduct?
        Virtusize.session = MockURLSession(data: TestFixtures.productDataCheckJsonResponse.data(using: .utf8),
                                           urlResponse: nil,
                                           error: nil)
        Virtusize.productCheck(product: TestFixtures.virtusizeProduct, completion: { product in
            acutalProduct = product
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        let dataObject = acutalProduct?.context?["data"] as? JSONObject
        let userData = dataObject?["userData"] as? JSONObject

        XCTAssertEqual(acutalProduct?.externalId, TestFixtures.prodcutId)
        XCTAssertEqual(acutalProduct?.imageURL, URL(string: TestFixtures.productImageUrl))
        XCTAssertEqual(dataObject?["productDataId"] as? Int ?? -1, 7110384)
        XCTAssertEqual(dataObject?["storeName"] as? String ?? "", "virtusize")
        XCTAssertEqual(dataObject?["storeId"] as? Int ?? -1, 2)
        XCTAssertEqual(dataObject?["productTypeName"] as? String ?? "", "pants")
        XCTAssertEqual(userData?["should_see_ph_tooltip"] as? Bool ?? true, false)
        XCTAssertEqual(dataObject?["fetchMetaData"] as? Bool ?? true, false)
        XCTAssertEqual(dataObject?["productTypeId"] as? Int ?? -1, 5)
        XCTAssertEqual(dataObject?["validProduct"] as? Bool ?? false, true)
    }

    func testSendProductImage_hasExpectedCallbackData() {
        let expectation = self.expectation(description: "Virtusize.sendProductImage reaches the callback")
        var actualObject: JSONObject?
        Virtusize.session = MockURLSession(data: TestFixtures.productMetaDataHintsJsonResponse.data(using: .utf8),
                                           urlResponse: nil,
                                           error: nil)
        Virtusize.sendProductImage(of: TestFixtures.virtusizeProduct, forStore: 2) { jsonObject in
            actualObject = jsonObject
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualObject?["apiKey"] as? String ?? "", Virtusize.APIKey)
        XCTAssertTrue(actualObject?["cloudinaryPublicId"] is String)
        XCTAssertEqual(actualObject?["externalProductId"] as? String ?? "", TestFixtures.prodcutId)
        XCTAssertEqual(actualObject?["imageUrl"] as? String ?? "", TestFixtures.productImageUrl)
    }

    func testSendEvent_UserSawProduct_hasExpectedCallbackData() {
        let expectation = self.expectation(description: "Virtusize.sendEvent reaches the callback")
        var actualObject: JSONObject?
        Virtusize.session = MockURLSession(data: TestFixtures.sendEventUserSawProductJsonResponse.data(using: .utf8),
                                           urlResponse: nil,
                                           error: nil)
        Virtusize.sendEvent(
            VirtusizeEvent(name: "user-saw-product",
                           data: nil),
            withContext: nil) { jsonObject in
                actualObject = jsonObject
                expectation.fulfill()
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualObject?["apiKey"] as? String ?? "", Virtusize.APIKey)
        XCTAssertEqual(actualObject?["browserId"] as? String ?? "", TestFixtures.browserID)
        XCTAssertEqual(actualObject?["name"] as? String ?? "", "user-saw-product")
    }

    func testRetrieveFullStoreInfo_success_hasExpectedRegion() {
        let expectation = self.expectation(description: "Virtusize.retrieveStoreInfo reaches the callback")
        var actualRegion: String?
        Virtusize.session = MockURLSession(data: TestFixtures.fullStoreInfoJsonResponse.data(using: .utf8),
                                                  urlResponse: nil,
                                                  error: nil)
        Virtusize.retrieveStoreInfo(completion: { region in
            actualRegion = region
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualRegion ?? "", "KR")
    }

    func testRetrieveStoreInfoWithSomeNullValues_success_hasExpectedRegion() {
        let expectation = self.expectation(description: "Virtusize.retrieveStoreInfo reaches the callback")
        var actualRegion: String?
        Virtusize.session = MockURLSession(
            data: TestFixtures.storeInfoWithSomeNullValuesJsonResponse.data(using: .utf8),
            urlResponse: nil,
            error: nil)
        Virtusize.retrieveStoreInfo(completion: { region in
            actualRegion = region
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualRegion ?? "", "JP")
    }

    func testRetrieveStoreInfo_withWrongAPIKey_hasExpectedError() {
        Virtusize.APIKey = "wrongAPIKey"
        let expectation = self.expectation(description: "Virtusize.retrieveStoreInfo reaches the callback")
        var actualError: VirtusizeError?

        Virtusize.session = MockURLSession(data: TestFixtures.retrieveStoreInfoErrorJsonResponse.data(using: .utf8),
                                                  urlResponse: nil,
                                                  error: nil)

        Virtusize.retrieveStoreInfo(completion: { _ in }, errorHandler: { error in
            actualError = error
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertNotNil(actualError)
        XCTAssertTrue(actualError!.debugDescription.contains(
            "Virtusize: Failed to decode the data response to the struct VirtusizeStore"))
    }

    func testSendOrder_withValidOrder_hasSuccessCallback() {
        let expectation = self.expectation(description: "Virtusize.sendOrder reaches the callback")
        var isSuccessful: Bool = false

        Virtusize.session = MockURLSession(data: nil,
                                           urlResponse: nil,
                                           error: nil)

        TestFixtures.virtusizeOrder.externalUserId = "123"
        TestFixtures.virtusizeOrder.region = "JP"
        Virtusize.sendOrderWithRegion(TestFixtures.virtusizeOrder, onSuccess: {
            isSuccessful = true
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertTrue(isSuccessful)
    }
}

extension VirtusizeTests {

    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    class MockURLSession: APISessionProtocol {

        var request: URLRequest?
        private let dataTask: MockTask

        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            dataTask = MockTask(data: data, urlResponse: urlResponse, error: error)
        }

        func dataTask(with request: URLRequest,
                      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            self.request = request
            dataTask.completionHandler = completionHandler
            return dataTask
        }
    }

    class MockTask: URLSessionDataTask {
        private let data: Data?
        private let urlResponse: URLResponse?
        private let responseError: Error?

        var completionHandler: CompletionHandler?

        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            self.data = data
            self.urlResponse = urlResponse
            self.responseError = error
        }

        override func resume() {
            DispatchQueue.main.async {
                self.completionHandler?(self.data, self.urlResponse, self.responseError)
            }
        }
    }
}
