//
//  VirtusizeServerProductAdditionalInfo.swift
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

/// This class represents the additional info of a store product
internal class VirtusizeServerProductAdditionalInfo: Codable {
	/// The brand of the store product
	let brand: String
	/// The gender for the store product
	let gender: String?
	/// The list of the product sizes
	let sizes: [String: [String: Int?]]
	/// The model info
	let modelInfo: [String: VirtusizeAnyCodable]?
	/// The general fit key
	let fit: String?
	/// The store product style
	let style: String?
	/// The brand sizing info
	let brandSizing: VirtusizeBrandSizing?

	private enum CodingKeys: String, CodingKey {
		case brand, gender, sizes, modelInfo, fit, style, brandSizing
	}

	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		brand = try values.decode(String.self, forKey: .brand)
		gender = try? values.decode(String.self, forKey: .gender)
		if let productSizes = try? values.decode([String: [String: Int?]].self, forKey: .sizes) {
			sizes = productSizes
		} else {
			sizes = [:]
		}
		modelInfo = try? values.decode([String: VirtusizeAnyCodable].self, forKey: .modelInfo)
		fit = try? values.decode(String.self, forKey: .fit)
		style = try? values.decode(String.self, forKey: .style)
		brandSizing = try? values.decode(VirtusizeBrandSizing.self, forKey: .brandSizing)
	}
}
