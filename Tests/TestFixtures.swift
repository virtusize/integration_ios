//
//  TestFixture.swift
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

struct TestFixtures {
    static let apiKey = "testApiKey"
    static let browserID = "browserID"
    static let externalProductId = "694"
    static let productId = 7110384
    static let productImageUrl = "http://www.example.com/image.jpg"

    static let emptyResponse = "{}"

    static let notFoundResponse = "{\"detail\": \"Not found.\"}"

    static let productDataCheckJsonResponse =
    """
        {
            "data":{
                "productTypeName": "pants",
                "storeName": "virtusize",
                "storeId": 2,
                "validProduct": true,
                "fetchMetaData": false,
                "productDataId": 7110384,
                "productTypeId": 5,
                "userData": {
                        "should_see_ph_tooltip": false,
                        "wardrobeActive": true
                    }
            },
            "name": "backend-checked-product",
            "productId": "\(externalProductId)"
        }
    """

    static let additionalEventData =
    """
        {
            "cloudinaryPublicId": "testCloudinaryPublicId",
            "productTypeId": 5,
            "size": "medium",
            "wardrobeBoughtItem": 3
        }
    """

    static let sendEventUserSawProductJsonResponse =
    """
       {
         "apiKey": "\(apiKey)",
         "name": "user-saw-product",
         "type": "user",
         "source": "integration-ios",
         "userCohort": "direct",
         "widgetType": "mobile",
         "browserOrientation": "portrait",
         "browserResolution": "667x375",
         "integrationVersion": "0.2",
         "snippetVersion": "0.2",
         "browserIp": "browseIp",
         "browserIpCountry": "JP",
         "browserIpCity": "Setagaya-ku",
         "ruuid": "ruuid",
         "browserId": "\(browserID)",
         "browserName": "xctest",
         "browserVersion": "2020.2.1",
         "browserPlatform": "other",
         "browserDevice": "other",
         "browserIsMobile": false,
         "browserIsTablet": false,
         "browserIsPc": false,
         "browserIsBot": false,
         "browserHasTouch": false,
         "browserLanguage": "en-us",
         "@timestamp": "2020-06-15T08:00:56.345768Z"
       }
    """

    static let productMetaDataHintsJsonResponse =
    """
        {
            "apiKey":"\(apiKey)",
            "cloudinaryPublicId":"7061ce42dc523f44ad8167f28f72ecb8b052fc96",
            "externalProductId":"694",
            "imageUrl":"\(productImageUrl)"
        }
    """

    static let fullStoreInfoJsonResponse =
    """
        {
            "id": 2,
            "surveyLink": "https://www.surveyLink.com",
            "name": "Virtusize",
            "shortName": "virtusize",
            "lengthUnitId": 2,
            "apiKey": "\(apiKey)",
            "created": "2011-01-01T00:00:00Z",
            "updated": "2020-04-20T02:33:58Z",
            "disabled": "2018-05-29 04:32:45",
            "typemapperEnabled": false,
            "region": "KR"
        }
    """

    static let storeInfoWithSomeNullValuesJsonResponse =
    """
        {
            "id": 2,
            "surveyLink": "https://www.surveyLink.com",
            "name": "Virtusize",
            "shortName": "virtusize",
            "lengthUnitId": 2,
            "apiKey": "\(apiKey)",
            "created": "2011-01-01T00:00:00Z",
            "updated": "2020-04-20T02:33:58Z",
            "disabled": null,
            "typemapperEnabled": false,
            "region": null
        }
    """

    static let retrieveStoreInfoErrorJsonResponse =
    """
        {
            "detail": "No store found"
        }
    """

    static let virtusizeOrderitem = VirtusizeOrderItem(
        productId: "A00001",
        size: "L",
        sizeAlias: "Large",
        variantId: "A00001_SIZEL_RED",
        imageUrl: productImageUrl,
        color: "Red",
        gender: "W",
        unitPrice: 5100.00,
        currency: "JPY",
        quantity: 1,
        url: "http://example.com/products/A00001"
    )

    static var virtusizeOrder = VirtusizeOrder(externalOrderId: "4000111032", items: [virtusizeOrderitem])

    static var virtusizeProduct = VirtusizeProduct(
        externalId: externalProductId,
        imageURL: URL(string: productImageUrl)
    )

    static let storeProductJsonResponse =
    """
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
          "productType":8,
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
                  "fit":"regular",
                  "brandSizing":{
                      "compare":"large",
                      "itemBrand":false
                  }
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
