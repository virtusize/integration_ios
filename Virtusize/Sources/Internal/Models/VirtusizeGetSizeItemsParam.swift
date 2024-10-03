//
//  VirtusizeGetSizeItemsParama.swift
//  Virtusize
//
//  Created by admin on 13/12/23.
//  Copyright © 2023 Virtusize AB. All rights reserved.
//

import Foundation
struct VirtusizeGetSizeItemsParam: Codable {

    var additionalInfo: [String: VirtusizeAnyCodable] = [:]
    var itemSizesOrig: [String: [String: Int?]] = [:]
    var productType: String
    var extProductId: String

}
