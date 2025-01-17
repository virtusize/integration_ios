//
//  VirtusizeServerProductMeta.swift
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

/// This class represents the meta data of a product
internal class VirtusizeServerProductMeta: Codable {
	/// The ID of the store product meta
	let id: Int
	/// The additional info of the store product
	let additionalInfo: VirtusizeServerProductAdditionalInfo?
	/// The brand name of the store product
	let brand: String
	/// The gender for the store product
	let gender: String?

	private enum CodingKeys: String, CodingKey {
		case id, additionalInfo, brand, gender
	}

	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		additionalInfo = try? values.decode(VirtusizeServerProductAdditionalInfo.self, forKey: .additionalInfo)
		brand = try values.decode(String.self, forKey: .brand)
		gender = try? values.decode(String.self, forKey: .gender)
	}
}
