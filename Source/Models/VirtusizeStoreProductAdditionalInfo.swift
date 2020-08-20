//
//  VirtusizeStoreProductAdditionalInfo.swift
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
internal class VirtusizeStoreProductAdditionalInfo: Codable {
    /// The general fit key
    let fit: String?
    /// The brand sizing info
    let brandSizing: VirtusizeBrandSizing?

    private enum CodingKeys: String, CodingKey {
        case fit, brandSizing
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fit = try? values.decode(String.self, forKey: .fit)
        brandSizing = try? values.decode(VirtusizeBrandSizing.self, forKey: .brandSizing)
    }

    /// Gets the general fit key for the fitting related InPage texts
    func getGeneralFitKey() -> String? {
        if fit == nil {
            return nil
        }
        if ["loose", "wide", "flared"].contains(fit) {
            return "loose"
        } else if ["tight", "slim"].contains(fit) {
            return "tight"
        }
        return "regular"
    }
}
