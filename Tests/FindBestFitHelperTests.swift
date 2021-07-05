//
//  FindBestFitHelperTests.swift
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

class FindBestFitHelperTests: XCTestCase {

    private let userShirtXS = getStoreProduct(
        productId: 1,
        sizes: [VirtusizeProductSize(
            "XS",
            [
                "bust": 500,
                "sleeve": 730,
                "height": 665,
                "shoulder": 400,
                "hem": 610
            ]
        )]
    )

    private let userShirtS = getStoreProduct(
        productId: 2,
        sizes: [VirtusizeProductSize(
            "S",
            [
                "bust": 520,
                "sleeve": 745,
                "height": 685,
                "shoulder": 410,
                "hem": 630
            ]
        )]
    )

    private let userShirtM = getStoreProduct(
        productId: 3,
        sizes: [VirtusizeProductSize(
            "M",
            [
                "bust": 540,
                "sleeve": 760,
                "height": 705,
                "shoulder": 420,
                "hem": 650
            ]
        )]
    )

    private let userShirtL = getStoreProduct(
        productId: 4,
        sizes: [VirtusizeProductSize(
            "L",
            [
                "bust": 570,
                "sleeve": 775,
                "height": 725,
                "shoulder": 430,
                "hem": 680
            ]
        )]
    )

    private let storeShirt = getStoreProduct(
        productId: 123,
        sizes: [VirtusizeProductSize(
            "Free",
            [
                "bust": 530,
                "sleeve": 770,
                "height": 690,
                "shoulder": 430,
                "collar": 360
            ]
        )]
    )

    private let shirtProductWeights = [
        "bust": 2.0,
        "sleeve": 1.0,
        "height": 0.5
    ]

    func testGetStoreProductFitInfo_withUserShirtXS_shouldHaveExpectedFitInfo() {
        let actualStoreProductFitInfo = FindBestFitHelper.getStoreProductFitInfo(
            userProductSize: userShirtXS.sizes[0],
            storeProductSize: storeShirt.sizes[0],
            storeProductTypeScoreWeights: shirtProductWeights
        )
        XCTAssertEqual(actualStoreProductFitInfo.fitScore, 88.75)
        XCTAssertFalse(actualStoreProductFitInfo.isSmaller!)
    }

    func testGetStoreProductFitInfo_withUserShirtS_shouldHaveExpectedFitInfo() {
        let actualStoreProductFitInfo = FindBestFitHelper.getStoreProductFitInfo(
            userProductSize: userShirtS.sizes[0],
            storeProductSize: storeShirt.sizes[0],
            storeProductTypeScoreWeights: shirtProductWeights
        )
        XCTAssertEqual(actualStoreProductFitInfo.fitScore, 95.25)
        XCTAssertFalse(actualStoreProductFitInfo.isSmaller!)
    }

    func testGetStoreProductFitInfo_withUserShirtM_shouldHaveExpectedFitInfo() {
        let actualStoreProductFitInfo = FindBestFitHelper.getStoreProductFitInfo(
            userProductSize: userShirtM.sizes[0],
            storeProductSize: storeShirt.sizes[0],
            storeProductTypeScoreWeights: shirtProductWeights
        )
        XCTAssertEqual(actualStoreProductFitInfo.fitScore, 96.25)
        XCTAssertTrue(actualStoreProductFitInfo.isSmaller!)
    }

    func testGetStoreProductFitInfo_withUserShirtL_shouldHaveExpectedFitInfo() {
        let actualStoreProductFitInfo = FindBestFitHelper.getStoreProductFitInfo(
            userProductSize: userShirtL.sizes[0],
            storeProductSize: storeShirt.sizes[0],
            storeProductTypeScoreWeights: shirtProductWeights
        )
        XCTAssertEqual(actualStoreProductFitInfo.fitScore, 89.75)
        XCTAssertTrue(actualStoreProductFitInfo.isSmaller!)
    }

    func testGetFindBestMatch_shouldReturnExpectedRecommendedSize() {
        let userShirts = [userShirtXS, userShirtS, userShirtM, userShirtL]
        let userProductRecommendedSize = FindBestFitHelper.findBestFitProductSize(
            userProducts: userShirts,
            storeProduct: storeShirt,
            productTypes: TestFixtures.getProductTypes()
        )
        XCTAssertEqual(userProductRecommendedSize?.bestFitScore, 96.25)
        XCTAssertEqual(userProductRecommendedSize?.bestUserProduct?.name, userShirts[2].name)
        XCTAssertTrue(userProductRecommendedSize!.isStoreProductSmaller!)
     }

    private static func getStoreProduct(
        productId: Int,
        sizes: [VirtusizeProductSize]
    ) -> VirtusizeStoreProduct {
        return VirtusizeStoreProduct(
            id: productId,
            sizes: sizes,
            externalId: "",
            productType: 2,
            name: "",
            cloudinaryPublicId: "",
            store: 2,
            isFavorite: false,
            storeProductMeta: nil
        )
    }
}
