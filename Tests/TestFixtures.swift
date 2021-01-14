//
//  TestFixture.swift
//
//  Copyright (c) 2018-present Virtusize KK
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
    static let prodcutId = "694"
    static let productImageUrl = "http://www.example.com/image.jpg"

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
            "productId": "\(prodcutId)"
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

    static var virtusizeProduct = VirtusizeProduct(externalId: prodcutId, imageURL: URL(string: productImageUrl))
}
