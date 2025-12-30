//
//  VirtusizeServerProductTests.swift
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

class VirtusizeServerProductTests: XCTestCase {

    private let storeProductFixture = Data(TestFixtures.getStoreProductJsonResponse(gender: nil).utf8)

    private var i18nLocalization = VirtusizeI18nLocalization()

	private let oneSizeProduct = TestFixtures.getOneSizeProduct()

    override func setUpWithError() throws {
        i18nLocalization.defaultAccessoryText = Localization.shared.localize("inpage_default_accessory_text")
		i18nLocalization.hasProductAccessoryTopText = Localization.shared.localize("inpage_has_product_top_text")
		i18nLocalization.hasProductAccessoryBottomText = Localization.shared.localize("inpage_has_product_bottom_text")
		i18nLocalization.oneSizeCloseTopText = Localization.shared.localize("inpage_one_size_close_top_text")
		i18nLocalization.oneSizeSmallerTopText = Localization.shared.localize("inpage_one_size_smaller_top_text")
		i18nLocalization.oneSizeLargerTopText = Localization.shared.localize("inpage_one_size_larger_top_text")
		i18nLocalization.oneSizeCloseBottomText = Localization.shared.localize("inpage_one_size_close_bottom_text")
		i18nLocalization.oneSizeSmallerBottomText = Localization.shared.localize("inpage_one_size_smaller_bottom_text")
		i18nLocalization.oneSizeLargerBottomText = Localization.shared.localize("inpage_one_size_larger_bottom_text")
		i18nLocalization.oneSizeWillFitResultText = Localization.shared.localize("inpage_one_size_will_fit_result_text")
		i18nLocalization.sizeComparisonMultiSizeText = Localization.shared.localize("inpage_multi_size_comparison_text")
		i18nLocalization.willFitResultText = Localization.shared.localize("inpage_will_fit_result")
        i18nLocalization.willNotFitResultText = Localization.shared.localize("inpage_will_not_fit_result")
        i18nLocalization.bodyDataEmptyText = Localization.shared.localize("inpage_body_data_empty_text")
    }

    func testDecoding_validServerProductData_shouldReturnExpectedStructure() {
        let storeProduct = try? JSONDecoder().decode(VirtusizeServerProduct.self, from: storeProductFixture)

        XCTAssertEqual(storeProduct?.id, TestFixtures.productId)
        XCTAssertEqual(storeProduct?.sizes.count, 3)
        XCTAssertEqual(storeProduct?.sizes[0].name, "35")
        XCTAssertEqual(storeProduct?.sizes[0].measurements, ["height": 740, "bust": 630, "sleeve": 805])
        XCTAssertEqual(storeProduct?.sizes[1].name, "37")
        XCTAssertEqual(storeProduct?.sizes[2].name, "36")
        XCTAssertEqual(storeProduct?.externalId, TestFixtures.externalProductId)
        XCTAssertEqual(storeProduct?.productType, 8)
        XCTAssertEqual(storeProduct?.name, "Test Product Name")
        XCTAssertEqual(storeProduct?.store, 2)
        XCTAssertEqual(storeProduct?.storeProductMeta?.id, 1)
        XCTAssertEqual(storeProduct?.storeProductMeta?.additionalInfo?.fit, "regular")
        XCTAssertEqual(storeProduct?.storeProductMeta?.additionalInfo?.brandSizing?.compare, "large")
        XCTAssertEqual(storeProduct?.storeProductMeta?.additionalInfo?.brandSizing?.itemBrand, false)
    }

    func testDecoding_emptyJsonData_shouldReturnNil() {
        let storeProduct = try? JSONDecoder().decode(
			VirtusizeServerProduct.self,
            from: Data(TestFixtures.emptyResponse.utf8)
        )

        XCTAssertNil(storeProduct)
    }

	func testGetRecommendationText_productIsAnAccessory_returnDefaultAccessoryText() {
		let storeProduct18 = TestFixtures.getStoreProduct(productType: 18, gender: nil)
		XCTAssertEqual(
			storeProduct18?.getRecommendationText(i18nLocalization, nil, nil),
			i18nLocalization.defaultAccessoryText
		)
		let storeProduct19 = TestFixtures.getStoreProduct(productType: 19, gender: nil)
		XCTAssertEqual(
			storeProduct19?.getRecommendationText(i18nLocalization, nil, nil),
			i18nLocalization.defaultAccessoryText
		)
		let storeProduct25 = TestFixtures.getStoreProduct(productType: 25, gender: nil)
		XCTAssertEqual(
			storeProduct25?.getRecommendationText(i18nLocalization, nil, nil),
			i18nLocalization.defaultAccessoryText)
	}

	func testGetRecommendationText_productIsAnAccessory_hasSizeComparisonRecommendedSize_returnHasProductAccessoryText() {
		var sizeComparisonRecommendedSize = SizeComparisonRecommendedSize()
		sizeComparisonRecommendedSize.bestUserProduct = TestFixtures.getStoreProduct(productType: 26, gender: nil)
		let storeProduct26 = TestFixtures.getStoreProduct(productType: 26, gender: nil)
		XCTAssertTrue(
			storeProduct26!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.hasProductAccessoryTopText!)
		)
		XCTAssertTrue(
			storeProduct26!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.hasProductAccessoryBottomText!)
		)
	}

	func testGetRecommendationText_oneSizeProduct_fitScoreLargerThan84_returnSizeComparisonOneSizeCloseText() {
		var sizeComparisonRecommendedSize = SizeComparisonRecommendedSize()
		sizeComparisonRecommendedSize.bestFitScore = 84.5
		XCTAssertTrue(
			oneSizeProduct!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.oneSizeCloseTopText!)
		)
		XCTAssertTrue(
			oneSizeProduct!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.oneSizeCloseBottomText!)
		)
	}

	func testGetRecommendationText_oneSizeProduct_storeProductIsSmaller_returnSizeComparisonOneSizeSmallerText() {
		var sizeComparisonRecommendedSize = SizeComparisonRecommendedSize()
		sizeComparisonRecommendedSize.isStoreProductSmaller = true
		XCTAssertTrue(
			oneSizeProduct!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.oneSizeSmallerTopText!)
		)
		XCTAssertTrue(
			oneSizeProduct!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.oneSizeSmallerBottomText!)
		)
	}

	func testGetRecommendationText_oneSizeProduct_storeProductIsLarger_returnSizeComparisonOneSizeLargerText() {
		var sizeComparisonRecommendedSize = SizeComparisonRecommendedSize()
		sizeComparisonRecommendedSize.bestFitScore = 60.0
		sizeComparisonRecommendedSize.isStoreProductSmaller = false
		XCTAssertTrue(
			oneSizeProduct!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.oneSizeLargerTopText!)
		)
		XCTAssertTrue(
			oneSizeProduct!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.oneSizeLargerBottomText!)
		)
	}

	func testGetRecommendationText_oneSizeProduct_onlyHasBodyProfileRecommendedSize_returnOneSizeBodyProfileText() {
		let bodyProfileRecommendedSizeName = "Small"
		XCTAssertTrue(
			oneSizeProduct!.getRecommendationText(
				i18nLocalization,
				nil,
				bodyProfileRecommendedSizeName,
                VirtusizeI18nLocalization.TrimType.ONELINE,
                true
			).contains(i18nLocalization.oneSizeWillFitResultText!)
		)
		XCTAssertTrue(
			oneSizeProduct!.getRecommendationText(
				i18nLocalization,
				nil,
				bodyProfileRecommendedSizeName,
                VirtusizeI18nLocalization.TrimType.ONELINE,
                true
			).contains(i18nLocalization.oneSizeWillFitResultText!)
		)
	}

    func testGetRecommendationText_oneSizeProduct_bodyProfileRecommendedSizeNotFit_returnOneSizeBodyProfileText() {
        let bodyProfileRecommendedSizeName = "Small"
        XCTAssertTrue(
            oneSizeProduct!.getRecommendationText(
                i18nLocalization,
                nil,
                bodyProfileRecommendedSizeName,
                VirtusizeI18nLocalization.TrimType.ONELINE,
                false
            ).contains(i18nLocalization.willNotFitResultText!)
        )
        XCTAssertTrue(
            oneSizeProduct!.getRecommendationText(
                i18nLocalization,
                nil,
                bodyProfileRecommendedSizeName,
                VirtusizeI18nLocalization.TrimType.ONELINE,
                false
            ).contains(i18nLocalization.willNotFitResultText!)
        )
    }

	func testGetRecommendationText_multiSizeProduct_hasSizeComparisonRecommendedSize_returnMultiSizeComparisonText() {
		let storeProduct1 = TestFixtures.getStoreProduct(productType: 1, gender: nil)
		var sizeComparisonRecommendedSize = SizeComparisonRecommendedSize()
		sizeComparisonRecommendedSize.bestStoreProductSize = storeProduct1?.sizes[0]
		XCTAssertTrue(
			storeProduct1!.getRecommendationText(
				i18nLocalization,
				sizeComparisonRecommendedSize,
				nil
			).contains(i18nLocalization.sizeComparisonMultiSizeText!)
		)
	}

	func testGetRecommendationText_multiSizeProduct_hasBodyProfileRecommendedSize_returnMultiSizeBodyProfileText() {
		let storeProduct4 = TestFixtures.getStoreProduct(productType: 4, gender: nil)
		let bodyProfileRecommendedSizeName = "S"
		XCTAssertTrue(
			storeProduct4!.getRecommendationText(
				i18nLocalization,
				nil,
				bodyProfileRecommendedSizeName,
                VirtusizeI18nLocalization.TrimType.ONELINE,
                true
			).contains(i18nLocalization.willFitResultText!)
		)
	}

    func testGetRecommendationText_multiSizeProduct_bodyProfileRecommendedSizeNotFit_returnMultiSizeBodyProfileText() {
        let storeProduct4 = TestFixtures.getStoreProduct(productType: 4, gender: nil)
        let bodyProfileRecommendedSizeName = "S"
        XCTAssertTrue(
            storeProduct4!.getRecommendationText(
                i18nLocalization,
                nil,
                bodyProfileRecommendedSizeName,
                VirtusizeI18nLocalization.TrimType.ONELINE,
                false
            ).contains(i18nLocalization.willNotFitResultText!)
        )
    }

	func testGetRecommendationText_multiSizeProduct_noRecommendedSizes_returnBodyDataEmptyText() {
		let storeProduct7 = TestFixtures.getStoreProduct(productType: 7, gender: nil)
		XCTAssertEqual(
			storeProduct7!.getRecommendationText(i18nLocalization, nil, nil),
            i18nLocalization.bodyDataEmptyText!
		)
	}
}
