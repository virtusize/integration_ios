//
//  VirtusizeGetSizeItemsParama.swift
//  Virtusize
//
//  Created by admin on 13/12/23.
//  Copyright © 2023 Virtusize AB. All rights reserved.
//

import Foundation
struct VirtusizeGetSizeItemsParam: Codable {
    internal init(additionalInfo: [String : VirtusizeAnyCodable] = [:], itemSizesOrig: [String : [String : Int?]] = [:],productType:  String, extProductId: String) {
        self.additionalInfo = additionalInfo
        self.itemSizesOrig = itemSizesOrig
        self.productType = productType
        self.extProductId = extProductId
        
    }
    
   
    var additionalInfo: [String: VirtusizeAnyCodable] = [:]
    var itemSizesOrig: [String: [String: Int?]] = [:]
    var productType: String
    var extProductId: String
    
   
  
}
