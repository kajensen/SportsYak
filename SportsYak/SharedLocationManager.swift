//
//  SharedLocationManager.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import CoreLocation

public class SharedLocationManager: CLLocationManager
{
    public class var sharedInstance: SharedLocationManager {
        struct Static
        {
            static var onceToken : dispatch_once_t = 0
            static var instance : SharedLocationManager? = nil
        }
        dispatch_once(&Static.onceToken)
            {
                Static.instance = SharedLocationManager()
        }
        return Static.instance!
    }
    
}
