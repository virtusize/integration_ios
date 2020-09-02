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
    /// The Cloudinary public ID corresponding to this store product
    let cloudinaryPublicId: String
    /// The ID of the store that this product belongs to
    let store: Int
    /// The additional data of type `VirtusizeStoreProductMeta`  represents the product
    let storeProductMeta: VirtusizeStoreProductMeta?

    private enum CodingKeys: String, CodingKey {
        // swiftlint:disable identifier_name
        case id, sizes, externalId, productType, name, cloudinaryPublicId, store, storeProductMeta
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        sizes = try values.decode([VirtusizeProductSize].self, forKey: .sizes)
        externalId = try values.decode(String.self, forKey: .externalId)
        productType = try values.decode(Int.self, forKey: .productType)
        name = try values.decode(String.self, forKey: .name)
        cloudinaryPublicId = try values.decode(String.self, forKey: .cloudinaryPublicId)
        store = try values.decode(Int.self, forKey: .store)
        storeProductMeta = try? values.decode(VirtusizeStoreProductMeta.self, forKey: .storeProductMeta)
    }

    /// Gets the InPage recommendation text based on the product info
    func getRecommendationText(i18nLocalization: VirtusizeI18nLocalization) -> String {
        var text = i18nLocalization.defaultText ?? Localization.shared.localize("inpage_default_text")
        if isAccessory() {
            text = i18nLocalization.defaultAccessoryText ??
                Localization.shared.localize("inpage_default_accessory_text")
        } else if let brandSizing = storeProductMeta?.additionalInfo?.brandSizing {
            text = i18nLocalization.getSizingText(brandSizing: brandSizing) ??
                Localization.shared.localize(
                    "inpage_sizing_\(brandSizing.getBrandKey())_\(brandSizing.compare)_text"
            )
        } else if let generalFitKey = storeProductMeta?.additionalInfo?.getGeneralFitKey() {
            text = i18nLocalization.getFitText(generalFitKey: generalFitKey) ??
                Localization.shared.localize("inpage_fit_\(generalFitKey)_text")
        }
        return text
    }

    /// Checks if the product is an accessory
    ///
    /// - Note: 18 is for bags, 19 is for clutches, 25 is for wallets and 26 is for props
    ///
    private func isAccessory() -> Bool {
        return productType == 18 || productType == 19 || productType == 25 || productType == 26
    }
}
