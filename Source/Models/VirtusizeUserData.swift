//
//  VirtusizeUserData.swift
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

/// This class represents the response for the user data field in the data field of ProductCheck
internal class VirtusizeUserData: Codable {
    let shouldSeePhTooltip: Bool?
    let wardrobeHasP: Bool?
    let wardrobeHasR: Bool?
    let wardrobeHasM: Bool?
    let wardrobeActive: Bool?

    private enum CodingKeys: String, CodingKey {
        case shouldSeePhTooltip = "should_see_ph_tooltip"
        case wardrobeHasP = "wardrobe_has_p"
        case wardrobeHasR = "wardrobe_has_r"
        case wardrobeHasM = "wardrobe_has_m"
        case wardrobeActive = "wardrobe_active"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        shouldSeePhTooltip = try? values.decode(Bool.self, forKey: .shouldSeePhTooltip)
        wardrobeHasP = try? values.decode(Bool.self, forKey: .wardrobeHasP)
        wardrobeHasR = try? values.decode(Bool.self, forKey: .wardrobeHasR)
        wardrobeHasM = try? values.decode(Bool.self, forKey: .wardrobeHasM)
        wardrobeActive = try? values.decode(Bool.self, forKey: .wardrobeActive)
    }
}
