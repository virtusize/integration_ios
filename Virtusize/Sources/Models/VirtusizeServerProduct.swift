//
//  VirtusizeServerProduct.swift
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

import UIKit
import Foundation
#if canImport(VirtusizeUIKit)
import VirtusizeUIKit
#endif

/// This structure represents a product from the Virtusize server
public class VirtusizeServerProduct: Codable {
	// swiftlint:disable identifier_name
	/// An integer to represent the internal product ID in the Virtusize server
	public let id: Int
	/// The list of the `VirtusizeProductSize` that this product has
	let sizes: [VirtusizeProductSize]
	/// A string to represent the external product ID from the client's store
	public let externalId: String
	/// The ID of the product type of this product
	public let productType: Int
	/// The product name
	let name: String
	/// The Cloudinary public ID for getting the store product image URL corresponding to this store product
	let cloudinaryPublicId: String
	/// The ID of the store that this product belongs to
	let store: Int
	/// The boolean value to show if this product is marked as a favorite
	let isFavorite: Bool?
	/// The additional data of type `VirtusizeServerProductMeta`  represents the product
	let storeProductMeta: VirtusizeServerProductMeta?

	/// The Cloudinary image URL string based on the cloudinary public ID
	public var cloudinaryImageUrlString: String? {
		guard !cloudinaryPublicId.isEmpty else {
			return nil
		}
		return "https://res.cloudinary.com/virtusize/image/upload/w_36,h_36/q_auto,f_auto,dpr_auto/\(cloudinaryPublicId).jpg"
	}

	/// The product style of this product
	public var productStyle: String? {
		return storeProductMeta?.additionalInfo?.style
	}

	private enum CodingKeys: String, CodingKey {
		// swiftlint:disable identifier_name
		case id, sizes, externalId, productType, name, cloudinaryPublicId, store, isFavorite, storeProductMeta
	}

	init(
		id: Int,
		sizes: [VirtusizeProductSize],
		externalId: String,
		productType: Int,
		name: String,
		cloudinaryPublicId: String,
		store: Int,
		isFavorite: Bool?,
		storeProductMeta: VirtusizeServerProductMeta?
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

	required public init(from decoder: Decoder) throws {
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
		storeProductMeta = try? values.decode(VirtusizeServerProductMeta.self, forKey: .storeProductMeta)
	}

	/// Gets the InPage recommendation text based on the user and store product info
	func getRecommendationText(
		_ i18nLocalization: VirtusizeI18nLocalization,
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		_ bodyProfileRecommendedSizeName: String?,
		_ trimType: VirtusizeI18nLocalization.TrimType = VirtusizeI18nLocalization.TrimType.ONELINE
	) -> String {
		var text = i18nLocalization.getNoDataText()
		if isAccessory() {
			text = accessoryText(i18nLocalization, sizeComparisonRecommendedSize)
		} else if self.sizes.count == 1 {
			text = oneSizeText(i18nLocalization, sizeComparisonRecommendedSize, bodyProfileRecommendedSizeName)
		} else {
			text = multiSizeText(i18nLocalization, sizeComparisonRecommendedSize, bodyProfileRecommendedSizeName)
		}
		return text.trimI18nText(trimType)
	}

	/// Gets the text for an accessory
	private func accessoryText(
		_ i18nLocalization: VirtusizeI18nLocalization,
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?
	) -> String {
		return sizeComparisonRecommendedSize?.bestUserProduct?.sizes[0].name != nil ?
			i18nLocalization.getHasProductAccessoryText() : i18nLocalization.getDefaultAccessoryText()
	}

	/// Gets the text for an one-size product
	private func oneSizeText(
		_ i18nLocalization: VirtusizeI18nLocalization,
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		_ bodyProfileRecommendedSizeName: String?
	) -> String {
		if let sizeComparisonRecommendedSize = sizeComparisonRecommendedSize, sizeComparisonRecommendedSize.isValid() {
			return i18nLocalization.getOneSizeProductComparisonText(sizeComparisonRecommendedSize)
		}
		if bodyProfileRecommendedSizeName != nil {
			return i18nLocalization.getOneSizeBodyProfileText()
		}
		return i18nLocalization.getNoDataText()
	}

	/// Gets the text for a multi-size product
	private func multiSizeText(
		_ i18nLocalization: VirtusizeI18nLocalization,
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		_ bodyProfileRecommendedSizeName: String?
	) -> String {
		if let sizeComparisonRecommendedSizeName = sizeComparisonRecommendedSize?.bestStoreProductSize?.name {
			return i18nLocalization.getMultiSizeProductionComparisonText(sizeComparisonRecommendedSizeName)
		}
		if let bodyProfileRecommendedSizeName = bodyProfileRecommendedSizeName {
			return i18nLocalization.getMultiSizeBodyProfileText(bodyProfileRecommendedSizeName)
		}
		return i18nLocalization.getNoDataText()
	}

	/// Checks if the product is an accessory
	///
	/// - Note: 18 is for bags, 19 is for clutches, 25 is for wallets and 26 is for props
	///
	private func isAccessory() -> Bool {
		return productType == 18 || productType == 19 || productType == 25 || productType == 26
	}

	/// Gets the Cloudinary image URL
	internal func getCloudinaryImageUrl() -> URL? {
		guard let imageUrlString = cloudinaryImageUrlString else {
			return nil
		}
		return URL(string: imageUrlString)
	}

	/// Gets the local product type image
	internal func getProductTypeImage() -> UIImage? {
		return VirtusizeAssets.getProductPlaceholderImage(
			productType: productType,
			style: storeProductMeta?.additionalInfo?.style
		)?.withPadding(inset: 8)?.withRenderingMode(.alwaysTemplate)
	}
}

extension VirtusizeServerProduct: Hashable {
	public static func == (lhs: VirtusizeServerProduct, rhs: VirtusizeServerProduct) -> Bool {
		return lhs.id == rhs.id && lhs.externalId == rhs.externalId
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
		hasher.combine(externalId)
	}
}
