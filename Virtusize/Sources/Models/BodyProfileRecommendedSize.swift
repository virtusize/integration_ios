//
//  BodyProfileRecommendedSize.swift
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

/// This structure represents the response for the recommendation API based on the user body profile


public struct BodyProfileRecommendedSize: Codable {
    let extProductId : String?
    let sizeName : String?
    let secondSize : String?
    let fitScore : Double?
    let secondFitScore : Double?
    let fitScoreDifference : Double?
    let virtualItem : VirtualItem?
    let willFit : Bool?
    let thresholdFitScore : Double?
    let scenario : String?
    let willFitForSizes : WillFitForSizes?
    
    init(extProductId: String? = nil, sizeName: String, secondSize: String? = nil, fitScore: Double? = nil, secondFitScore: Double? = nil, fitScoreDifference: Double? = nil, virtualItem: VirtualItem? = nil, willFit : Bool? = nil, thresholdFitScore: Double? = nil, scenario : String? = nil, willFitForSizes: WillFitForSizes? = nil ) {
        self.extProductId = extProductId
        self.sizeName = sizeName
        self.secondSize = secondSize
        self.fitScore = fitScore
        self.secondFitScore = secondFitScore
        self.fitScoreDifference = fitScoreDifference
        self.virtualItem = virtualItem
        self.willFit = willFit
        self.thresholdFitScore = thresholdFitScore
        self.scenario = scenario
        self.willFitForSizes = willFitForSizes
    }
}
public typealias BodyProfileRecommendedSizeArray = [BodyProfileRecommendedSize]
// MARK: - VirtualItem
struct VirtualItem: Codable {
    let bust : Double?
    let waist : Double?
    let hip : Double?
    let inseam: String?
    let sleeve: String?
}

// MARK: - WillFitForSizes
struct WillFitForSizes: Codable {
    let large : Bool?
    let  medium  : Bool?
    let extraSmall: Bool?
    let extraLarge: Bool?
    let small: Bool?
    
    
    enum CodingKeys: String, CodingKey {

        case large = "large"
        case medium = "medium"
        case extraSmall = "extra small"
        case extraLarge = "extra large"
        case small = "small"
        
    }
}


