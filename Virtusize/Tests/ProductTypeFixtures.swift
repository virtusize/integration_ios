//
//  ProductTypeFixtures.swift
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
    static let productTypeOneJsonResponse =
    """
        {
            "id": 1,
            "name": "dress",
            "weights": {
              "bust": 1,
              "waist": 1,
              "height": 0.25
            },
            "compatibleWith": [
              1,
              16
            ]
        }
    """

    static let productTypeTwoJsonResponse =
    """
        {
            "id": 2,
            "name": "shirt",
            "weights": {
                "bust": 2,
                "height": 0.5,
                "sleeve": 1
            },
            "compatibleWith":[
                2
            ]
        }
    """

    static let productTypeEightJsonResponse =
    """
        {
         "id": 8,
         "name": "jacket",
         "weights": {
           "bust": 2,
           "height": 1,
           "sleeve": 1
         },
         "compatibleWith": [
           8,
           14
         ]
        }
    """

    static let productTypeEighteenJsonResponse =
    """
        {
            "id":18,
            "name": "bag",
            "weights":{
                "depth":1,
                "width":2,
                "height":1
            },
            "compatibleWith":[
                18,
                19,
                25,
                26
            ]
        }
    """

    static let productTypeArrayJsonResponse =
    """
        [
            \(productTypeOneJsonResponse),
            \(productTypeTwoJsonResponse),
            \(productTypeEightJsonResponse),
            \(productTypeEighteenJsonResponse)
        ]
    """

    static func getProductTypes() -> [VirtusizeProductType] {
        if let productTypes = try? JSONDecoder().decode(
            [VirtusizeProductType].self,
            from: productTypeArrayJsonResponse.data(using: .utf8) ?? Data()
        ) {
            return productTypes
        }
        return []
    }
}
