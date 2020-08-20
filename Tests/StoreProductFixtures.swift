//
//  StoreProductFixtures.swift
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

    static func getStoreProductJsonResponse( // swiftlint:disable:this function_body_length
        productType: Int = 8,
        brandSizing: VirtusizeBrandSizing? = VirtusizeBrandSizing(compare: "large", itemBrand: false),
        fit: String = "regular"
    ) -> String {
        return """
            {
              "id":\(productId),
              "sizes":[
                  {
                      "name":"35",
                      "measurements":{
                          "height":740,
                          "bust":630,
                          "sleeve":805
                      }
                  },
                  {
                      "name":"37",
                      "measurements":{
                          "height":760,
                          "bust":660,
                          "sleeve":845
                      }
                  },
                  {
                      "name":"36",
                      "measurements":{
                          "height":750,
                          "bust":645,
                          "sleeve":825
                      }
                  }
              ],
              "isSgi":false,
              "created":"2020-01-29T09:48:55Z",
              "updated":"2020-01-29T09:52:01Z",
              "deleted":null,
              "externalId":"\(externalProductId)",
              "productType":\(productType),
              "name":"Test Product Name",
              "cloudinaryPublicId":"Test Cloudinary Public Id",
              "store":2,
              "storeProductMeta":{
                  "id":1,
                  "modelInfo":{
                      "hip":85,
                      "size":"38",
                      "waist":56,
                      "bust":78,
                      "height":165
                  },
                  "materials":{
                      "main":{
                          "polyamide":1.0
                      },
                      "fill":{
                          "feather":0.1,
                          "down":0.9
                      },
                      "sleeve lining":{}
                  },
                  "matAnalysis":{
                      "lining":{
                          "none":true,
                          "some":false,
                          "present":false
                      },
                      "elasticity":{
                          "none":false,
                          "some":true,
                          "present":false
                      },
                      "transparency":{
                          "none":false,
                          "some":true,
                          "present":false
                      },"thickness":{
                          "heavy":true,
                          "light":false,
                          "normal":false
                      }
                  },
                  "additionalInfo":{
                      "brand":"Virtusize",
                      "gender":"female",
                      "sizes":{
                          "38":{
                              "height":760,
                              "bust":660,
                              "sleeve":845
                          },
                          "36":{
                              "height":750,
                              "bust":645,
                              "sleeve":825
                          }
                      },
                      "modelInfo":{
                          "hip":85,
                          "size":"38",
                          "waist":56,
                          "bust":78,
                          "height":165
                      },
                      "type":"regular",
                      "style":"fashionable",
                      "fit":"\(fit)",
                      "brandSizing": \(getBrandSizingJsonResponse(brandSizing))
                  },
                  "price":{
                      "eur":230
                  },
                  "salePrice":{
                      "eur":60
                  },
                  "availableSizes":[
                      "36",
                      "38"
                  ],
                  "attributes":{
                      "defaults":false,
                      "jacket_style":"fashionable",
                      "tops_fit":"regular"
                  },
                  "created":"2020-01-29T09:48:57Z",
                  "updated":"2020-01-29T09:48:57Z",
                  "brand":"Virtusize",
                  "active":true,
                  "url":"https://www.virtusize.co.jp/shop/goods.html?id=694",
                  "gender":"female",
                  "color":null,
                  "style":null,
                  "storeProduct":\(productId)
              }
            }
        """
    }

    private static func getBrandSizingJsonResponse(_ brandSizing: VirtusizeBrandSizing?) -> String {
        if brandSizing == nil {
            return "null"
        } else {
            return """
                {
                    "compare":"\(brandSizing!.compare)",
                    "itemBrand":\(brandSizing!.itemBrand)
                }
            """
        }
    }
}
