//
//  Constants.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/23/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class Constants {
    static let GLOBAL_TINT = UIColor(hex: 0xDCAB24)
    static let GLOBAL_TINT_SECONDARY = UIColor(hex: 0x24dcab)
    static let GLOBAL_TINT_TERTIARY = UIColor(hex: 0x2455dc)
}

extension UIColor {
    convenience init(hexString : String) {
        let hexInt = strtoul(hexString, nil, 16)
        self.init(hex: Int(hexInt))
    }
    convenience init(hex : Int) {
        let blue = CGFloat(hex & 0xFF)
        let green = CGFloat((hex >> 8) & 0xFF)
        let red = CGFloat((hex >> 16) & 0xFF)
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
}

class Notifications {
    static let KARMA_UPDATED = "notificationKarmaUpdated"
}