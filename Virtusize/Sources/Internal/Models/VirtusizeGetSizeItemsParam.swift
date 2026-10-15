//
//  Copyright (c) 2023 Virtusize KK
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

import Foundation
struct VirtusizeGetSizeItemsParam: Codable {
    var additionalInfo: [String: VirtusizeAnyCodable] = [:]
    var itemSizesOrig: [String: [String: Int?]] = [:]
    var productType: String
    var extProductId: String
    /// The web widget sends this on the item, not inside `additionalInfo`. Always null today.
    var fitAdjust: String? = nil

    enum CodingKeys: String, CodingKey {
        case additionalInfo, itemSizesOrig, productType, extProductId, fitAdjust
    }

    init(
        additionalInfo: [String: VirtusizeAnyCodable] = [:],
        itemSizesOrig: [String: [String: Int?]] = [:],
        productType: String,
        extProductId: String,
        fitAdjust: String? = nil
    ) {
        self.additionalInfo = additionalInfo
        self.itemSizesOrig = itemSizesOrig
        self.productType = productType
        self.extProductId = extProductId
        self.fitAdjust = fitAdjust
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        additionalInfo = try container.decode([String: VirtusizeAnyCodable].self, forKey: .additionalInfo)
        itemSizesOrig = try container.decode([String: [String: Int?]].self, forKey: .itemSizesOrig)
        productType = try container.decode(String.self, forKey: .productType)
        extProductId = try container.decode(String.self, forKey: .extProductId)
        fitAdjust = try container.decodeIfPresent(String.self, forKey: .fitAdjust)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(additionalInfo, forKey: .additionalInfo)
        try container.encode(itemSizesOrig, forKey: .itemSizesOrig)
        try container.encode(productType, forKey: .productType)
        try container.encode(extProductId, forKey: .extProductId)
        if let fitAdjust {
            try container.encode(fitAdjust, forKey: .fitAdjust)
        } else {
            try container.encodeNil(forKey: .fitAdjust)
        }
    }
}
