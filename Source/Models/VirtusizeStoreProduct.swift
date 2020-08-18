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

internal class VirtusizeStoreProduct: Codable {
    let id: Int
    let sizes: [VirtusizeProductSize]
    let externalId: String
    let productType: Int
    let name: String
    let store: Int
    let storeProductMeta: VirtusizeStoreProductMeta?

    private enum CodingKeys: String, CodingKey {
        case id, sizes, externalId, productType, name, store, storeProductMeta
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        sizes = try values.decode([VirtusizeProductSize].self, forKey: .sizes)
        externalId = try values.decode(String.self, forKey: .externalId)
        productType = try values.decode(Int.self, forKey: .productType)
        name = try values.decode(String.self, forKey: .name)
        store = try values.decode(Int.self, forKey: .store)
        storeProductMeta = try? values.decode(VirtusizeStoreProductMeta.self, forKey: .storeProductMeta)
    }

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

    private func isAccessory() -> Bool {
        return productType == 18 || productType == 19 || productType == 25 || productType == 26
    }
}
