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

/// This structure represents a product from the Virtusize server
public class VirtusizeServerProduct: Codable {
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

    private lazy var imageSize: Int = Int(VirtusizeProductImageView.circleImageSize * pow(UIScreen.main.scale, 2))

	/// The Cloudinary image URL string based on the cloudinary public ID
	public var cloudinaryImageUrlString: String? {
		guard !cloudinaryPublicId.isEmpty else {
			return nil
		}
		// swiftlint:disable:next line_length
        return "https://res.cloudinary.com/virtusize/image/upload/w_\(imageSize),h_\(imageSize)/q_auto:best,f_auto,dpr_auto/\(cloudinaryPublicId).jpg"
	}

	/// The product style of this product
	public var productStyle: String? {
		return storeProductMeta?.additionalInfo?.style
	}

	private enum CodingKeys: String, CodingKey {
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
		_ i18nLocalization: VirtusizeI18nLocalization?,
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		_ bodyProfileRecommendedSizeName: String?,
		_ trimType: VirtusizeI18nLocalization.TrimType = VirtusizeI18nLocalization.TrimType.ONELINE,
		_ bodyProfileWillFit: Bool? = nil
	) -> String {
        guard let i18nLocalization = i18nLocalization else {
            return Localization.shared.localize("inpage_default_accessory_text")
        }

		var text = i18nLocalization.getBodyDataEmptyText()
		if isAccessory() {
			text = accessoryText(i18nLocalization, sizeComparisonRecommendedSize)
		} else if self.sizes.count == 1 {
			text = oneSizeText(i18nLocalization, sizeComparisonRecommendedSize, bodyProfileRecommendedSizeName, bodyProfileWillFit)
		} else {
			text = multiSizeText(i18nLocalization, sizeComparisonRecommendedSize, bodyProfileRecommendedSizeName, bodyProfileWillFit)
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
		_ bodyProfileRecommendedSizeName: String?,
		_ bodyProfileWillFit: Bool?
	) -> String {
		// Check if body data is provided (bodyProfileRecommendedSizeName is not nil means body data was provided)
		let hasBodyData = bodyProfileRecommendedSizeName != nil

		// For one-size products with body data provided
		if hasBodyData {
			// If willFit is true and we have a recommended size, show the will fit message
			if bodyProfileWillFit == true {
				return i18nLocalization.getOneSizeBodyProfileText()
			}
			// If willFit is false or no recommended size, show "Your size not found"
			return i18nLocalization.getWillNotFitResultText()
		}

		// No body data provided, check for product comparison
		if let sizeComparisonRecommendedSize = sizeComparisonRecommendedSize, sizeComparisonRecommendedSize.isValid() {
			return i18nLocalization.getOneSizeProductComparisonText(sizeComparisonRecommendedSize)
		}

		// No data at all, show body data empty message
		return i18nLocalization.getBodyDataEmptyText()
	}

	/// Gets the text for a multi-size product
	private func multiSizeText(
		_ i18nLocalization: VirtusizeI18nLocalization,
		_ sizeComparisonRecommendedSize: SizeComparisonRecommendedSize?,
		_ bodyProfileRecommendedSizeName: String?,
		_ bodyProfileWillFit: Bool?
	) -> String {
		// Check if body data is provided
		let hasBodyData = bodyProfileRecommendedSizeName != nil

		// For multi-size products with body data provided
		if hasBodyData {
			// If willFit is true and we have a recommended size, show it
			if bodyProfileWillFit == true, let bodyProfileRecommendedSizeName = bodyProfileRecommendedSizeName, !bodyProfileRecommendedSizeName.isEmpty {
				return i18nLocalization.getMultiSizeBodyProfileText(bodyProfileRecommendedSizeName)
			}
			// If willFit is false or no recommended size, show "Your size not found"
			return i18nLocalization.getWillNotFitResultText()
		}

		// No body data provided, check for product comparison
		if let sizeComparisonRecommendedSizeName = sizeComparisonRecommendedSize?.bestStoreProductSize?.name {
			return i18nLocalization.getMultiSizeProductionComparisonText(sizeComparisonRecommendedSizeName)
		}

		// No data at all, show body data empty message
		return i18nLocalization.getBodyDataEmptyText()
	}

	/// Checks if the product is an accessory
	///
	/// - Note: 18 is for bags, 19 is for clutches, 25 is for wallets and 26 is for props
	///
	private func isAccessory() -> Bool {
		return productType == 18 || productType == 19 || productType == 25 || productType == 26
	}

	/// Checks if the product is a shoe
    internal func isShoe() -> Bool {
		return productType == 17
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
		// Use UTF-8 bytes instead of String to avoid Unicode normalization issues
		// that can crash with malformed Unicode sequences
        // TODO: find Unicode externalId error
		hasher.combine(externalId.utf8.map { $0 })
	}
}
