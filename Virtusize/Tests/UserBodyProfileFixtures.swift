//
//  UserBodyProfileFixtures.swift
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

import Foundation
@testable import Virtusize

extension TestFixtures {

    static let userBodyProfileFixture = Data(
        """
            {
                "wardrobe": "1234567",
                "gender": "female",
                "age": 32,
                "height": 1630,
                "weight": "50.00",
                "braSize": {},
                "concernAreas": {},
                "bodyData": {
                    "hip": 830,
                    "bust": 755,
                    "neck": 300,
                    "rise": 215,
                    "bicep": 220,
                    "thigh": 480,
                    "waist": 630,
                    "inseam": 700,
                    "sleeve": 720,
                    "shoulder": 370,
                    "hipWidth": 300,
                    "bustWidth": 245,
                    "hipHeight": 750,
                    "headHeight": 215,
                    "kneeHeight": 395,
                    "waistWidth": 225,
                    "waistHeight": 920,
                    "armpitHeight": 1130,
                    "sleeveLength": 520,
                    "shoulderWidth": 340,
                    "shoulderHeight": 1240
                }
            }
        """.utf8
    )

    static let emptyUserBodyProfileFixture = Data(
    """
        {
           "gender": "",
           "age": null,
           "height": null,
           "weight": null,
           "braSize": null,
           "concernAreas": null,
           "bodyData": null
        }
    """.utf8
    )

    static func getUserBodyProfile() -> VirtusizeUserBodyProfile? {
        return try? JSONDecoder().decode(VirtusizeUserBodyProfile.self, from: Data(userBodyProfileFixture))
    }
}
