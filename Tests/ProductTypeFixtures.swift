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

extension TestFixtures {
    static let productTypeOneJsonResponse =
    """
        {
             "id": 1,
             "name": "dress",
             "optionalMeasurements": [
               "hip",
               "sleeveOpening",
               "hem",
               "waistHeight"
             ],
             "priority": [
               "bust",
               "waist",
               "height"
             ],
             "requiredMeasurements": [
               "height",
               "bust",
               "waist"
             ],
             "supportsLengthComparison": true,
             "weights": {
               "bust": 1,
               "waist": 1,
               "height": 0.25
             },
             "anchorPoint": "shoulders",
             "compatibleWith": [
               1,
               16
             ],
             "defaultMeasurements": {
               "hem": 470,
               "hip": 440,
               "bust": 430,
               "waist": 395,
               "height": 900,
               "waistHeight": 410,
               "sleeveOpening": 200
             },
             "displayMode": "portrait",
             "isDraggable": false,
             "isReserved": false,
             "maxMeasurements": {
               "hem": 2000,
               "hip": 1500,
               "bust": 1200,
               "waist": 1200,
               "height": 2500,
               "waistHeight": 750,
               "sleeveOpening": 400
             },
             "minMeasurements": {
               "hem": 200,
               "hip": 150,
               "bust": 150,
               "waist": 100,
               "height": 500,
               "waistHeight": 150,
               "sleeveOpening": 50
             },
             "sgiGenders": [
               "female"
             ],
             "sgiStyles": [
               "regular"
             ],
             "sgiTypes": [
               "medium",
               "long",
               "short"
             ]
         }
    """

    static let productTypeEighteenJsonResponse =
    """
            {
             "id":18,
             "name":"bag",
             "optionalMeasurements":[
                 "topWidth",
                 "handleDrop",
                 "handleWidth"
             ],
             "priority":[
                 "width",
                 "height",
                 "depth"
             ],
             "requiredMeasurements":[
                 "height",
                 "width",
                 "depth"
             ],
             "supportsLengthComparison":true,
             "weights":{
                 "depth":1,
                 "width":2,
                 "height":1
             },
             "anchorPoint":"shoulders",
             "compatibleWith":[
                 18,
                 19,
                 25,
                 26
             ],
             "defaultMeasurements":{
                 "depth":70,
                 "width":340,
                 "height":190,
                 "topWidth":300,
                 "handleDrop":100,
                 "handleWidth":140
             },
             "displayMode":"landscape",
             "isDraggable":true,
             "isReserved":false,
             "maxMeasurements":{
                 "depth":1000,
                 "width":1000,
                 "height":1000,
                 "topWidth":1000,
                 "handleDrop":1000,
                 "handleWidth":1000
             },
             "minMeasurements":{
                 "depth":10,
                 "width":50,
                 "height":50,
                 "topWidth":50,
                 "handleDrop":10,
                 "handleWidth":10
             },
             "sgiGenders":[
                 "male",
                 "female",
                 "unisex"
             ],
             "sgiStyles":[
             ],
             "sgiTypes":[
             ]
         }
    """

    static let productTypeArrayJsonResponse =
    """
        [
            \(productTypeOneJsonResponse),
            \(productTypeEighteenJsonResponse)
        ]
    """
}
