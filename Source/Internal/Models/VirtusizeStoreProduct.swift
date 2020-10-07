//
//  VirtusizeStoreProduct.swift
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

/// This structure represents a store product from the Virtusize server
internal class VirtusizeStoreProduct: Codable {
    // swiftlint:disable identifier_name
    /// An integer to represent the internal product ID in the Virtusize server
    let id: Int
    /// The list of the `VirtusizeProductSize` that this product has
    let sizes: [VirtusizeProductSize]
    /// A string to represent the external product ID from the client's store
    let externalId: String
    /// The ID of the product type of this product
    let productType: Int
    /// The product name
    let name: String
    /// The Cloudinary public ID for getting the store product image URL corresponding to this store product
    let cloudinaryPublicId: String
    /// The ID of the store that this product belongs to
    let store: Int
    /// The boolean value to show if this product is marked as a favorite
    let isFavorite: Bool?
    /// The additional data of type `VirtusizeStoreProductMeta`  represents the product
    let storeProductMeta: VirtusizeStoreProductMeta?

    private enum CodingKeys: String, CodingKey {
        // swiftlint:disable identifier_name
        case id, sizes, externalId, productType, name, cloudinaryPublicId, store, isFavorite, storeProductMeta
    }

    init(id: Int,
         sizes: [VirtusizeProductSize],
         externalId: String,
         productType: Int,
         name: String,
         cloudinaryPublicId: String,
         store: Int,
         isFavorite: Bool?,
         storeProductMeta: VirtusizeStoreProductMeta?
    ) {
        self.id = id
        self.sizes = sizes
        self.externalId = externalId
        self.productType = productType
        self.name = name
        self.cloudinaryPublicId = cloudinaryPublicId
        self.store = store
        self.isFavorite = isFavorite
        self.storeProductMeta = storeProductMeta

    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        sizes = try values.decode([VirtusizeProductSize].self, forKey: .sizes)
        if let externalId = try? values.decode(String.self, forKey: .externalId) {
            self.externalId = externalId
        } else {
            self.externalId = ""
        }
        productType = try values.decode(Int.self, forKey: .productType)
        name = try values.decode(String.self, forKey: .name)
        if let cloudinaryPublicId = try? values.decode(String.self, forKey: .cloudinaryPublicId) {
            self.cloudinaryPublicId = cloudinaryPublicId
        } else {
            self.cloudinaryPublicId = ""
        }
        if let store = try? values.decode(Int.self, forKey: .store) {
            self.store = store
        } else {
            self.store = 0
        }
        isFavorite = try? values.decode(Bool.self, forKey: .isFavorite)
        storeProductMeta = try? values.decode(VirtusizeStoreProductMeta.self, forKey: .storeProductMeta)
    }

    /// Gets the InPage recommendation text based on the user and store product info
    func getRecommendationText(
        _ i18nLocalization: VirtusizeI18nLocalization,
        _ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
        _ bodyProfileRecommendedSizeName: String?,
        _ trimType: VirtusizeI18nLocalization.TrimType = VirtusizeI18nLocalization.TrimType.ONELINE
    ) -> String {
        var text = noDataText(i18nLocalization)
        if isAccessory() {
            if let accessoryText = accessoryText(i18nLocalization, sizeComparisonRecommendedSize) {
                text = accessoryText
            }
        } else if self.sizes.count == 1 {
            text = oneSizeText(i18nLocalization, sizeComparisonRecommendedSize, bodyProfileRecommendedSizeName)
        } else {
            text = multiSizeText(i18nLocalization, sizeComparisonRecommendedSize, bodyProfileRecommendedSizeName)
        }
        return text.trimI18nText(trimType)
    }

	// TODO: add comment
    private func noDataText(_ i18nLocalization: VirtusizeI18nLocalization) -> String {
        return i18nLocalization.noDataText ?? Localization.shared.localize("inpage_no_data_text")
    }

    private func accessoryText(
        _ i18nLocalization: VirtusizeI18nLocalization,
        _ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?
    ) -> String? {
        return sizeComparisonRecommendedSize?.bestUserProduct?.sizes[0].name != nil ?
            i18nLocalization.getHasProductAccessoryText() : i18nLocalization.defaultAccessoryText
    }

    private func oneSizeText(
        _ i18nLocalization: VirtusizeI18nLocalization,
        _ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
        _ bodyProfileRecommendedSizeName: String?
    ) -> String {
		if let sizeComparisonRecommendedSize = sizeComparisonRecommendedSize,
		   let sizeComparisonOneSizeText = i18nLocalization.getSizeComparisonOneSizeText(
			sizeComparisonRecommendedSize
		   ) {
			return sizeComparisonOneSizeText
		}
        if bodyProfileRecommendedSizeName != nil,
           let bodyProfileOneSizeText = i18nLocalization.bodyProfileOneSizeText {
            return bodyProfileOneSizeText
        }
        return noDataText(i18nLocalization)
    }

    private func multiSizeText(
        _ i18nLocalization: VirtusizeI18nLocalization,
        _ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
        _ bodyProfileRecommendedSizeName: String?
    ) -> String {
		if let sizeComparisonRecommendedSizeName = sizeComparisonRecommendedSize?.bestUserProduct?.sizes[0].name,
		   let sizeComparisonMultiSizeText = i18nLocalization.getSizeComparisonMultiSizeText(
			sizeComparisonRecommendedSizeName
		   ) {
			return sizeComparisonMultiSizeText
		}
        if let bodyProfileRecommendedSizeName = bodyProfileRecommendedSizeName,
           let bodyProfileMultiSizeText = i18nLocalization.getBodyProfileMultiSizeText(bodyProfileRecommendedSizeName) {
            return bodyProfileMultiSizeText
        }
        return noDataText(i18nLocalization)
    }

    /// Checks if the product is an accessory
    ///
    /// - Note: 18 is for bags, 19 is for clutches, 25 is for wallets and 26 is for props
    ///
    private func isAccessory() -> Bool {
        return productType == 18 || productType == 19 || productType == 25 || productType == 26
    }
}
