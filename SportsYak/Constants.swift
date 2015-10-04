//
//  Constants.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/23/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class Constants {
    static let NOTIFICATION_UPDATED_KARMA = "kSYnotificationKarmaUpdated"
    static let GLOBAL_TINT = UIColor(hex: 0xDCAB24)
    static let GLOBAL_TINT_SECONDARY = UIColor(hex: 0x24dcab)
    static let GLOBAL_TINT_TERTIARY = UIColor(hex: 0x2455dc)
    static let FLAT_COLORS = [0xDA3030, 0xE2682A, 0xFCC409, 0xEDD8AA, 0x28384B, 0x202020,
                                0x88409D, 0x2A5C6B, 0x2486CC, 0x31C567, 0x2BB18C, 0xE8ECEE,
                                0x7F9192, 0x254E34, 0x6346B1, 0x4C3428, 0x4C2449, 0xE95967,
                                0x91BA41, 0xEE61B6, 0x682121, 0x927360, 0xAABBEA, 0x3F5090];
    static let USER_IMAGE_NAMES = ["baseball", "basketball", "bowling", "boxing", "dumbbell", "football", "medal", "net", "pingpong", "rollerblade", "soccer", "trophy", "volleyball", "whistle"];
    
    class func randomColorIndex() -> Int {
        return Int(arc4random_uniform(UInt32(Constants.FLAT_COLORS.count)))
    }
    
    class func randomImageIndex() -> Int {
        return Int(arc4random_uniform(UInt32(Constants.USER_IMAGE_NAMES.count)))
    }
    
    class func userColor(index: Int) -> UIColor {
        if (index >= 0 && index < Constants.FLAT_COLORS.count) {
            let hexInt = Constants.FLAT_COLORS[index]
            return UIColor(hex: hexInt)
        }
        else if (index == -1) {
            return GLOBAL_TINT
        }
        return UIColor.clearColor()
    }
    
    class func userImage(index: Int) -> UIImage? {
        if (index >= 0 && index < Constants.USER_IMAGE_NAMES.count) {
            let imageName = Constants.USER_IMAGE_NAMES[index]
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        else if (index == -1) {
            if let image = UIImage(named: "op") {
                return image
            }
        }
        return nil
    }
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
