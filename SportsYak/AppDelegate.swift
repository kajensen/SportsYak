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
import BRYXBanner
import FBSDKCoreKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Instabug.startWithToken("53b85f046af0ad35e9a95866fe72adf2", captureSource: IBGCaptureSourceUIKit, invocationEvent: IBGInvocationEventShake)

        PFMember.registerSubclass()
        PFNFLTeam.registerSubclass()
        PFNBATeam.registerSubclass()
        PFMLBTeam.registerSubclass()
        PFPost.registerSubclass()
        PFComment.registerSubclass()
        PFEvent.registerSubclass()
        PFNotification.registerSubclass()
        PFFlag.registerSubclass()
        
        Parse.setApplicationId("dKZqBjSRUJV3H9QU2aIqLQFX5dMsoSBT1rBGjPoF",
            clientKey: "wV3wBuIFJN8sCI0AdjiA9vvMkU9Ms2J9oCXNs6W0")
        
        PFUser.enableAutomaticUser()
        print("launching with user \(PFMember.currentUser())")

        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let locationManager = SharedLocationManager.sharedInstance
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        refreshUser()
        
        let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]);
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        //UI
        //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.magentaColor()], forState:.Normal)
        UITabBar.appearance().tintColor = Constants.GLOBAL_TINT
        UISwitch.appearance().onTintColor = Constants.GLOBAL_TINT
        
        if let tabItemFont = UIFont(name: "Din Alternate", size: 10) {
            UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName:tabItemFont], forState: UIControlState.Normal)
        }
        if let navigationBarFont = UIFont(name: "DinAlternate-Bold", size: 20) {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName:navigationBarFont,NSForegroundColorAttributeName:UIColor.whiteColor()]
        }
        if let barButtonFont = UIFont(name: "Din Alternate", size: 18) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName:barButtonFont,NSForegroundColorAttributeName:Constants.GLOBAL_TINT], forState: UIControlState.Normal)
        }
        if let segmentedControlFont = UIFont(name: "Din Alternate", size: 12) {
            UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName:segmentedControlFont], forState: UIControlState.Normal)
        }

        // push
        // Extract the notification data
        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            // don't really need to use this...
            print(notificationPayload)
        }

        Fabric.with([Crashlytics.self])

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // LOCATION
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            updateLocation()
        }
    }
    
    func updateLocation() {
        if let user = PFMember.currentUser() {
            if let location = SharedLocationManager.sharedInstance.location {
                print("saving location \(location)")
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
                                print("refreshed user")
                                user.nflTeam = fetchedUser.nflTeam
                                user.nbaTeam = fetchedUser.nbaTeam
                                user.mlbTeam = fetchedUser.mlbTeam
                            }
                        } else {
                            print("Error: \(error!) \(error!.userInfo)")
                        }
                    })
                }
            }
        }
    }
    
    // PUSH
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        if let _ = PFMember.currentUser() {
            // GET NOTIFICATIONS
            if let message = userInfo["message"] as? String {
                let banner = Banner(title: "Notification", subtitle: message, image: nil, backgroundColor: Constants.GLOBAL_TINT)
                banner.dismissesOnTap = true
                banner.show(duration: 2.0)
            }
            completionHandler(UIBackgroundFetchResult.NewData)
        }
        else {
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        if let user = PFMember.currentUser() {
            installation.setValue(user, forKey: "user")
        }
        installation.saveInBackground()
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
        CoreData.stack.syncKarma()
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CoreData.stack.saveContext()
    }

    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
}

