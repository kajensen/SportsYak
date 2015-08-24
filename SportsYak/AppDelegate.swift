 //
//  AppDelegate.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        PFMember.registerSubclass()
        PFNFLTeam.registerSubclass()
        PFPost.registerSubclass()
        PFComment.registerSubclass()
        PFEvent.registerSubclass()
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        // Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("dKZqBjSRUJV3H9QU2aIqLQFX5dMsoSBT1rBGjPoF",
            clientKey: "wV3wBuIFJN8sCI0AdjiA9vvMkU9Ms2J9oCXNs6W0")
        
        PFUser.enableAutomaticUser()
        println("launching with user \(PFMember.currentUser())")

        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let locationManager = SharedLocationManager.sharedInstance
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        refreshUser()
        
        //UI
        //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.magentaColor()], forState:.Normal)
        UITabBar.appearance().tintColor = Constants.GLOBAL_TINT
        
        return true
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            updateLocation()
        }
    }
    
    func updateLocation() {
        if let user = PFMember.currentUser() {
            if let location = SharedLocationManager.sharedInstance.location {
                println("saving location \(location)")
                user.location = PFGeoPoint(location: location)
                user.saveInBackground()
            }
        }
    }
    
    func refreshUser() {
        if let user = PFMember.currentUser() {
            if user.objectId == nil {
                user.setup()
                user.saveInBackground()
            }
            else if let query = PFMember.queryWithIncludes() {
                if let userId = user.objectId {
                    query.whereKey("objectId", equalTo:userId)
                    query.getFirstObjectInBackgroundWithBlock({ (object : PFObject?, error: NSError?) -> Void in
                        if error == nil {
                            if let fetchedUser = object as? PFMember {
                                println("refreshed user")
                                user.nflTeam = fetchedUser.nflTeam
                            }
                        } else {
                            println("Error: \(error!) \(error!.userInfo!)")
                        }
                    })
                }
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

