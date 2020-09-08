//
//  VirtusizeStoreProductTests.swift
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

class VirtusizeStoreProductTests: XCTestCase {

    private let storeProductFixture = Data(TestFixtures.getStoreProductJsonResponse().utf8)

    private var i18nLocalization = VirtusizeI18nLocalization()

    override func setUpWithError() throws {
        i18nLocalization.defaultText = Localization.shared.localize("inpage_default_text")
        i18nLocalization.defaultAccessoryText = Localization.shared.localize("inpage_default_accessory_text")
        i18nLocalization.sizingItemBrandLargeText = Localization.shared.localize(
        "inpage_sizing_itemBrand_large_text")
        i18nLocalization.sizingItemBrandTrueText = Localization.shared.localize(
        "inpage_sizing_itemBrand_true_text")
        i18nLocalization.sizingItemBrandSmallText = Localization.shared.localize(
        "inpage_sizing_itemBrand_small_text")
        i18nLocalization.sizingMostBrandsLargeText = Localization.shared.localize(
               "inpage_sizing_mostBrands_large_text")
        i18nLocalization.sizingMostBrandsTrueText = Localization.shared.localize(
        "inpage_sizing_mostBrands_true_text")
        i18nLocalization.sizingMostBrandsSmallText = Localization.shared.localize(
        "inpage_sizing_mostBrands_small_text")
        i18nLocalization.fitLooseText = Localization.shared.localize("inpage_fit_loose_text")
        i18nLocalization.fitRegularText = Localization.shared.localize("inpage_fit_regular_text")
        i18nLocalization.fitTightText = Localization.shared.localize("inpage_fit_tight_text")
    }

    func testDecoding_validStoreProductData_shouldReturnExpectedStructure() {
        let storeProduct = try? JSONDecoder().decode(VirtusizeStoreProduct.self, from: storeProductFixture)

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
            VirtusizeStoreProduct.self,
            from: Data(TestFixtures.emptyResponse.utf8)
        )

        XCTAssertNil(storeProduct)
    }

    func testGetRecommendationText_productIsAnAccessory_returnDefaultAccessoryText() {
        let defaultAccessoryText = Localization.shared.localize("inpage_default_accessory_text")
        let storeProduct18 = getStoreProduct(productType: 18)
        XCTAssertEqual(storeProduct18?.getRecommendationText(i18nLocalization: i18nLocalization), defaultAccessoryText)
        let storeProduct19 = getStoreProduct(productType: 19)
        XCTAssertEqual(storeProduct19?.getRecommendationText(i18nLocalization: i18nLocalization), defaultAccessoryText)
         let storeProduct25 = getStoreProduct(productType: 25)
        XCTAssertEqual(storeProduct25?.getRecommendationText(i18nLocalization: i18nLocalization), defaultAccessoryText)
         let storeProduct26 = getStoreProduct(productType: 26)
        XCTAssertEqual(storeProduct26?.getRecommendationText(i18nLocalization: i18nLocalization), defaultAccessoryText)
    }

    func testGetRecommendationText_brandSizingIsNotNull_returnBrandSizingText() {
        XCTAssertEqual(
            getStoreProduct(
                productType: 1,
                brandSizing: VirtusizeBrandSizing(compare: "large", itemBrand: true))?
                .getRecommendationText(i18nLocalization: i18nLocalization),
            Localization.shared.localize("inpage_sizing_itemBrand_large_text").trimI18nText()
        )
        XCTAssertEqual(
            getStoreProduct(
                productType: 15,
                brandSizing: VirtusizeBrandSizing(compare: "true", itemBrand: true))?
                .getRecommendationText(i18nLocalization: i18nLocalization),
            Localization.shared.localize("inpage_sizing_itemBrand_true_text").trimI18nText()
        )
        XCTAssertEqual(
            getStoreProduct(
                productType: 20,
                brandSizing: VirtusizeBrandSizing(compare: "small", itemBrand: false))?
                .getRecommendationText(i18nLocalization: i18nLocalization),
            Localization.shared.localize("inpage_sizing_mostBrands_small_text").trimI18nText()
        )
        XCTAssertEqual(
            getStoreProduct(
                productType: 24,
                brandSizing: VirtusizeBrandSizing(compare: "true", itemBrand: false))?
                .getRecommendationText(i18nLocalization: i18nLocalization),
            Localization.shared.localize("inpage_sizing_mostBrands_true_text").trimI18nText()
        )
    }

    func testGetRecommendationText_brandSizingIsNullAndGeneralFitIsNotNull_returnGeneralFitText() {
        XCTAssertEqual(
            getStoreProduct(
                productType: 4,
                brandSizing: nil,
                fit: "regular")?
                .getRecommendationText(i18nLocalization: i18nLocalization),
            Localization.shared.localize("inpage_fit_regular_text").trimI18nText()
        )
        XCTAssertEqual(
            getStoreProduct(
                productType: 6,
                brandSizing: nil,
                fit: "loose")?
                .getRecommendationText(i18nLocalization: i18nLocalization),
            Localization.shared.localize("inpage_fit_loose_text").trimI18nText()
        )
        XCTAssertEqual(
            getStoreProduct(
                productType: 8,
                brandSizing: nil,
                fit: "flared")?
                .getRecommendationText(i18nLocalization: i18nLocalization),
            Localization.shared.localize("inpage_fit_loose_text").trimI18nText()
        )
        XCTAssertEqual(
            getStoreProduct(
                productType: 10,
                brandSizing: nil,
                fit: "slim")?
                .getRecommendationText(i18nLocalization: i18nLocalization),
            Localization.shared.localize("inpage_fit_tight_text").trimI18nText()
        )
        XCTAssertEqual(
                   getStoreProduct(
                       productType: 12,
                       brandSizing: nil,
                       fit: "random")?
                       .getRecommendationText(i18nLocalization: i18nLocalization),
                   Localization.shared.localize("inpage_fit_regular_text").trimI18nText()
               )
    }

    private func getStoreProduct(
        productType: Int = 8,
        brandSizing: VirtusizeBrandSizing? = VirtusizeBrandSizing(compare: "large", itemBrand: false),
        fit: String = "regular"
    ) -> VirtusizeStoreProduct? {
        return try? JSONDecoder().decode(
            VirtusizeStoreProduct.self,
            from: Data(
                TestFixtures.getStoreProductJsonResponse(
                    productType: productType,
                    brandSizing: brandSizing,
                    fit: fit).utf8
                )
            )
    }
}
