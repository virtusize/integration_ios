//
//  UserProductFixtures.swift
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

extension TestFixtures {

    static let userProductOneJsonResponse =
    """
        {
          "id": 123456,
          "sizes": [
            {
              "name": "S",
              "measurements": {
                "height": 1000,
                "bust": 400,
                "waist": 340,
                "hip": null,
                "hem": null,
                "waistHeight": null
              }
            }
          ],
          "productType": 11,
          "created": "2020-09-14T11:06:00Z",
          "updated": "2020-09-14T11:06:00Z",
          "name": "Test Womenswear Strapless Dress",
          "cloudinaryPublicId": null,
          "deleted": false,
          "isFavorite": false,
          "wardrobe": 123,
          "orderItem": null,
          "store": null
        }
    """

    static let userProductTwoJsonResponse =
    """
        {
           "id": 654321,
           "sizes": [
               {
                   "name": null,
                   "measurements": {
                       "height": 820,
                       "bust": 520,
                       "sleeve": 930,
                       "collar": null,
                       "shoulder": null,
                       "waist": null,
                       "hem": null,
                       "bicep": null
                   }
               }
           ],
           "productType": 2,
           "created": "2020-07-22T10:22:19Z",
           "updated": "2020-07-22T10:22:19Z",
           "name": "test2",
           "cloudinaryPublicId": null,
           "deleted": false,
           "isFavorite": true,
           "wardrobe": 123,
           "orderItem": null,
           "store": 2
        }
    """

    static let userProductArrayJsonResponse =
    """
        [
            \(userProductOneJsonResponse),
            \(userProductTwoJsonResponse)
        ]
    """

    static let emptyProductArrayJsonResponse = "[]"

    static let wardrobeNotFoundErrorJsonResponse = "{\"detail\": \"No wardrobe found\"}"
}
