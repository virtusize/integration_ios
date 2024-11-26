//
//  VirtusizeAPIServiceTests.swift
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
@testable import VirtusizeCore

// swiftlint:disable type_body_length file_length
class VirtusizeAPIServiceTests: XCTestCase {

    override func setUpWithError() throws {
        Virtusize.APIKey = TestFixtures.apiKey
        Virtusize.userID = "123"
        Virtusize.environment = .STAGING
    }

    func testFetchLatestAoyamaVersion() {
        let expectation = self.expectation(description: "Virtusize.fetchLatestAoyamaVersion reaches the callback")
        var actualVersion: String?
        DispatchQueue.global().async {

            actualVersion = VirtusizeAPIService.fetchLatestAoyamaVersion().success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualVersion, VirtusizeConfiguration.defaultAoyamaVersion)
    }

    func testProductCheck_hasExpectedCallbackData() {
        let expectation = self.expectation(description: "Virtusize.productCheck reaches the callback")
        var actualProduct: VirtusizeProduct?
        VirtusizeAPIService.session = MockURLSession(data: TestFixtures.productCheckJsonResponse.data(using: .utf8),
                                                     urlResponse: nil,
                                                     error: nil)
        DispatchQueue.global().async {

            actualProduct = VirtusizeAPIService.productCheckAsync(product: TestFixtures.virtusizeProduct).success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        let productCheckData = actualProduct?.productCheckData

        XCTAssertEqual(actualProduct?.externalId, TestFixtures.externalProductId)
        XCTAssertEqual(productCheckData?.productDataId, 7110384)
        XCTAssertEqual(productCheckData?.storeName, "virtusize")
        XCTAssertEqual(productCheckData?.storeId, 2)
        XCTAssertEqual(productCheckData?.productTypeName, "pants")
        XCTAssertEqual(productCheckData?.userData?.shouldSeePhTooltip, false)
        XCTAssertEqual(productCheckData?.fetchMetaData, false)
        XCTAssertEqual(productCheckData?.productTypeId, 5)
        XCTAssertEqual(productCheckData?.validProduct, true)
    }

    func testSendProductImage_hasExpectedCallbackData() {
        let expectation = self.expectation(description: "Virtusize.sendProductImage reaches the callback")
        var actualObject: JSONObject?
        VirtusizeAPIService.session = MockURLSession(data: TestFixtures.productMetaDataHintsJsonResponse.data(using: .utf8),
                                                     urlResponse: nil,
                                                     error: nil)
        VirtusizeAPIService.sendProductImage(of: TestFixtures.virtusizeProduct, forStore: 2) { jsonObject in
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
        XCTAssertEqual(actualObject?["externalProductId"] as? String ?? "", TestFixtures.externalProductId)
        XCTAssertEqual(actualObject?["imageUrl"] as? String ?? "", TestFixtures.productImageUrl)
    }

    func testSendEvent_UserSawProduct_hasExpectedCallbackData() {
        let expectation = self.expectation(description: "Virtusize.sendEvent reaches the callback")
        var actualObject: JSONObject?
        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.sendEventUserSawProductJsonResponse.data(using: .utf8),
            urlResponse: nil,
            error: nil
        )

        VirtusizeAPIService.sendEvent(
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
        VirtusizeAPIService.session = MockURLSession(data: TestFixtures.fullStoreInfoJsonResponse.data(using: .utf8),
                                                     urlResponse: nil,
                                                     error: nil)

        DispatchQueue.global().async {

            actualRegion = VirtusizeAPIService.retrieveStoreInfoAsync().success?.region

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

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
        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.storeInfoWithSomeNullValuesJsonResponse.data(using: .utf8),
            urlResponse: nil,
            error: nil)

        DispatchQueue.global().async {

            actualRegion = VirtusizeAPIService.retrieveStoreInfoAsync().success?.region

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualRegion, nil)
    }

    func testRetrieveStoreInfo_withWrongAPIKey_hasExpectedError() {
        Virtusize.APIKey = "wrongAPIKey"
        let expectation = self.expectation(description: "Virtusize.retrieveStoreInfo reaches the callback")
        var actualError: VirtusizeError?

        let requestURL = "https://staging.virtusize.com/a/api/v3/stores/api-key/\(Virtusize.APIKey!)?format=json"
        let response = HTTPURLResponse(url: URL(string: requestURL)!, statusCode: 403, httpVersion: nil, headerFields: nil)
        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.retrieveStoreInfoErrorJsonResponse.data(using: .utf8),
            urlResponse: response,
            error: nil
        )

        DispatchQueue.global().async {

            actualError = VirtusizeAPIService.retrieveStoreInfoAsync().failure

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertNotNil(actualError)
        XCTAssertEqual(
            actualError!.debugDescription,
            VirtusizeError.apiRequestError(
                URL(string: requestURL)!,
                TestFixtures.retrieveStoreInfoErrorJsonResponse).debugDescription
        )
    }

    func testSendOrder_withValidOrder_hasSuccessCallback() {
        let expectation = self.expectation(description: "Virtusize.sendOrder reaches the callback")
        var isSuccessful: Bool = false

        VirtusizeAPIService.session = MockURLSession(data: nil,
                                                     urlResponse: nil,
                                                     error: nil)

        TestFixtures.virtusizeOrder.externalUserId = "123"
        TestFixtures.virtusizeOrder.region = "JP"

        DispatchQueue.global().async {

            isSuccessful = VirtusizeAPIService.sendOrderWithRegionAsync(TestFixtures.virtusizeOrder).isSuccessful

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertTrue(isSuccessful)
    }

    func testGetStoreProductInfo_withValidProductId_hasExpectedStoreProduct() {
        let expectation = self.expectation(description: "Virtusize.getStoreProductInfo reaches the callback")
        var actualStoreProduct: VirtusizeServerProduct?

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.getStoreProductJsonResponse(gender: nil).data(using: .utf8),
            urlResponse: nil,
            error: nil
        )

        DispatchQueue.global().async {

            actualStoreProduct = VirtusizeAPIService.getStoreProductInfoAsync(productId: TestFixtures.productId).success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualStoreProduct?.id, TestFixtures.productId)
        XCTAssertEqual(actualStoreProduct?.sizes.count, 3)
        XCTAssertEqual(actualStoreProduct?.sizes[0].name, "35")
        XCTAssertEqual(actualStoreProduct?.sizes[0].measurements, ["height": 740, "bust": 630, "sleeve": 805])
        XCTAssertEqual(actualStoreProduct?.sizes[1].name, "37")
        XCTAssertEqual(actualStoreProduct?.sizes[2].name, "36")
        XCTAssertEqual(actualStoreProduct?.externalId, TestFixtures.externalProductId)
        XCTAssertEqual(actualStoreProduct?.productType, 8)
        XCTAssertEqual(actualStoreProduct?.name, "Test Product Name")
        XCTAssertEqual(actualStoreProduct?.store, 2)
        XCTAssertEqual(actualStoreProduct?.storeProductMeta?.id, 1)
        XCTAssertEqual(actualStoreProduct?.storeProductMeta?.additionalInfo?.fit, "regular")
        XCTAssertEqual(actualStoreProduct?.storeProductMeta?.additionalInfo?.brandSizing?.compare, "large")
    }

    func testGetStoreProductInfo_productNotFound_hasExpectedErrorMessage() {
        let storeProductId = 123456789
        let storeProductUrl = "https://staging.virtusize.com/a/api/v3/store-products/\(storeProductId)?format=json"
        let notFoundURLResponse = HTTPURLResponse(url: URL(string: storeProductUrl)!,
                                                  statusCode: 404,
                                                  httpVersion: nil,
                                                  headerFields: [:])!

        let expectation = self.expectation(description: "Virtusize.getStoreProductInfo reaches the callback")
        var virtusizeError: VirtusizeError?

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.notFoundResponse.data(using: .utf8),
            urlResponse: notFoundURLResponse,
            error: nil
        )

        DispatchQueue.global().async {

            virtusizeError = VirtusizeAPIService.getStoreProductInfoAsync(productId: storeProductId).failure

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertNotNil(virtusizeError?.debugDescription)
        XCTAssertTrue(virtusizeError!.debugDescription.contains(TestFixtures.notFoundResponse))
    }

    func testGetUserProducts_hasExpectedUserProductList() {
        let expectation = self.expectation(description: "Virtusize.getUserProducts reaches the callback")
        var actualUserProductList: [VirtusizeServerProduct]?

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.userProductArrayJsonResponse.data(using: .utf8),
            urlResponse: nil,
            error: nil
        )

        DispatchQueue.global().async {

            actualUserProductList = VirtusizeAPIService.getUserProductsAsync().success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualUserProductList?.count, 2)
        XCTAssertEqual(actualUserProductList?[0].id, 123456)
        XCTAssertEqual(actualUserProductList?[0].sizes.count, 1)
        XCTAssertEqual(actualUserProductList?[0].sizes[0].name, "S")
        XCTAssertEqual(actualUserProductList?[1].id, 654321)
        XCTAssertEqual(actualUserProductList?[1].sizes[0].name, nil)
        XCTAssertEqual(
            actualUserProductList?[1].sizes[0].measurements,
            [
                "height": 820,
                "bust": 520,
                "sleeve": 930
            ]
        )
        XCTAssertEqual(actualUserProductList?[1].productType, 2)
        XCTAssertEqual(actualUserProductList?[1].name, "test2")
        XCTAssertEqual(actualUserProductList?[1].cloudinaryPublicId, "")
        XCTAssertEqual(actualUserProductList?[1].isFavorite, true)
    }

    func testGetUserProducts_userHasAnEmptyWardrobe_hasExpectedEmptyUserProductList() {
        let expectation = self.expectation(description: "Virtusize.getUserProducts reaches the callback")
        var actualUserProductList: [VirtusizeServerProduct]?

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.emptyProductArrayJsonResponse.data(using: .utf8),
            urlResponse: nil,
            error: nil
        )

        DispatchQueue.global().async {

            actualUserProductList = VirtusizeAPIService.getUserProductsAsync().success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualUserProductList?.count, 0)
    }

    func testGetUserProducts_userWardrobeDoesNotExist_return404Error() {
        let expectation = self.expectation(description: "Virtusize.getUserProducts reaches the callback")
        var actualError: VirtusizeError?

        let userProductUrl = "https://staging.virtusize.com/a/api/v3/user-products"
        let notFoundURLResponse = HTTPURLResponse(url: URL(string: userProductUrl)!,
                                                  statusCode: 404,
                                                  httpVersion: nil,
                                                  headerFields: [:])!

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.wardrobeNotFoundErrorJsonResponse.data(using: .utf8),
            urlResponse: notFoundURLResponse,
            error: nil
        )

        DispatchQueue.global().async {

            actualError = VirtusizeAPIService.getUserProductsAsync().failure

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertNotNil(actualError)
        XCTAssertTrue(actualError!.debugDescription.contains("{\"detail\": \"No wardrobe found\"}"))
    }

    func testGetProductTypes_hasExpectedProductTypes() {
        let expectation = self.expectation(description: "Virtusize.getStoreProductInfo reaches the callback")
        var actualProductTypes: [VirtusizeProductType] = []

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.productTypeArrayJsonResponse.data(using: .utf8),
            urlResponse: nil,
            error: nil
        )

        DispatchQueue.global().async {

            actualProductTypes = VirtusizeAPIService.getProductTypesAsync().success ?? []

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualProductTypes.count, 4)
        XCTAssertEqual(actualProductTypes[0].id, 1)
        XCTAssertEqual(actualProductTypes[0].weights, ["bust": 1, "waist": 1, "height": 0.25])
        XCTAssertEqual(actualProductTypes[3].id, 18)
        XCTAssertEqual(actualProductTypes[3].weights, ["depth": 1, "width": 2, "height": 1])
    }

    func testGetI18nTexts_hasExpectedI18nLocalization() {
        let expectation = self.expectation(description: "Virtusize.getI18nTexts reaches the callback")
        var actualI18nLocalization: VirtusizeI18nLocalization?

        VirtusizeAPIService.session = MockURLSession(
            data: TestUtils.shared.loadTestJsonFile(jsonFileName: "i18n_ko"),
            urlResponse: nil,
            error: nil
        )

        DispatchQueue.global().async {

            actualI18nLocalization = VirtusizeAPIService.getI18nTextsAsync().success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        let localizedLang = VirtusizeLanguage.KOREAN

        XCTAssertEqual(
            actualI18nLocalization?.defaultAccessoryText,
            Localization.shared.localize("inpage_default_accessory_text", language: localizedLang)
        )
        XCTAssertEqual(
            actualI18nLocalization?.bodyDataEmptyText,
            Localization.shared.localize("inpage_body_data_empty_text", language: localizedLang)
        )
    }

    func testGetUserBodyProfile_whenRecieveValidUserBodyProfile_hasExpectedUserBodyProfile() {
        let expectation = self.expectation(description: "Virtusize.getUserBodyProfile reaches the callback")
        var actualUserBodyProfile: VirtusizeUserBodyProfile?

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.userBodyProfileFixture,
            urlResponse: nil,
            error: nil
        )

        DispatchQueue.global().async {

            actualUserBodyProfile = VirtusizeAPIService.getUserBodyProfileAsync().success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertEqual(actualUserBodyProfile?.gender, "female")
        XCTAssertEqual(actualUserBodyProfile?.age, 32)
        XCTAssertEqual(actualUserBodyProfile?.height, 1630)
        XCTAssertEqual(actualUserBodyProfile?.weight, "50.00")
        XCTAssertEqual(
            actualUserBodyProfile?.bodyData,
            [
                "hip": 830,
                "bust": 755,
                "neck": 300,
                "rise": 215,
                "bicep": 220,
                "thigh": 480,
                "waist": 630,
                "inseam": 700,
                "sleeve": 720,
                "shoulder": 370,
                "hipWidth": 300,
                "bustWidth": 245,
                "hipHeight": 750,
                "headHeight": 215,
                "kneeHeight": 395,
                "waistWidth": 225,
                "waistHeight": 920,
                "armpitHeight": 1130,
                "sleeveLength": 520,
                "shoulderWidth": 340,
                "shoulderHeight": 1240
            ]
        )
    }

    func testGetUserBodyProfile_whenRecieveEmptyUserBodyProfile_hasExpectedUserBodyProfile() {
        let expectation = self.expectation(description: "Virtusize.getUserBodyProfile reaches the callback")
        var actualUserBodyProfile: VirtusizeUserBodyProfile?

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.emptyUserBodyProfileFixture,
            urlResponse: nil,
            error: nil
        )

        DispatchQueue.global().async {

            actualUserBodyProfile = VirtusizeAPIService.getUserBodyProfileAsync().success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertNotNil(actualUserBodyProfile)
        XCTAssertEqual(actualUserBodyProfile?.gender, "")
        XCTAssertNil(actualUserBodyProfile?.age)
        XCTAssertNil(actualUserBodyProfile?.height)
        XCTAssertNil(actualUserBodyProfile?.weight)
        XCTAssertNil(actualUserBodyProfile?.bodyData)
    }

    func testGetUserBodyProfile_userWardrobeDoesNotExist_return404Error() {
        let expectation = self.expectation(description: "Virtusize.getUserBodyProfile reaches the callback")
        var actualError: VirtusizeError?

        let userBodyMeasurementsUrl = "https://staging.virtusize.com/a/api/v3/user-body-measurements"
        let notFoundURLResponse = HTTPURLResponse(url: URL(string: userBodyMeasurementsUrl)!,
                                                  statusCode: 404,
                                                  httpVersion: nil,
                                                  headerFields: [:])!

        VirtusizeAPIService.session = MockURLSession(
            data: TestFixtures.wardrobeNotFoundErrorJsonResponse.data(using: .utf8),
            urlResponse: notFoundURLResponse,
            error: nil
        )

        DispatchQueue.global().async {

            actualError = VirtusizeAPIService.getUserBodyProfileAsync().failure

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertNotNil(actualError)
        XCTAssertTrue(actualError!.debugDescription.contains("{\"detail\": \"No wardrobe found\"}"))
    }

    func testGetUserBodyRecommendedSize() {
        let expectation = self.expectation(description: "Virtusize.getUserBodyRecommendedSize reaches the callback")
        var actualRecommendedSizes: BodyProfileRecommendedSizeArray?

        VirtusizeAPIService.session = MockURLSession(
            data: "[{\"sizeName\": \"35\"}]".data(using: .utf8),
            urlResponse: nil,
            error: nil
        )

        DispatchQueue.global().async {
            actualRecommendedSizes = VirtusizeAPIService.getBodyProfileRecommendedSizesAsync(
                productTypes: TestFixtures.getProductTypes(),
                storeProduct: TestFixtures.getStoreProduct(gender: "female")!,
                userBodyProfile: TestFixtures.getUserBodyProfile()!
            ).success

            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectations error: \(error)")
            }
        }

        XCTAssertNotNil(actualRecommendedSizes)
        XCTAssertEqual(actualRecommendedSizes?.first?.sizeName, "35")
    }
}

extension VirtusizeAPIServiceTests {

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
