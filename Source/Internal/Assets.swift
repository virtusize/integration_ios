//
//  Assets.swift
//  Virtusize
//
//  Created by Zaidin Amiot on 2018/11/15.
//  Copyright © 2018 Virtusize AB. All rights reserved.
//

import Foundation

final internal class Assets {
    private static let bundle = Bundle(for: Assets.self)

    public static let primaryColor: UIColor = #colorLiteral(red: 0.09, green: 0.78, blue: 0.73, alpha: 1)
    public static let icon: UIImage? = {
        return UIImage(named: "vs-v-icon", in: bundle, compatibleWith: nil)
    }()
    public static let logo: UIImage? = {
        return UIImage(named: "vs-v-logo", in: bundle, compatibleWith: nil)
    }()
    public static let cancel: UIImage? = {
        return UIImage(named: "vs-cancel-icon", in: bundle, compatibleWith: nil)
    }()
}
