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
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var hasFetchedUserComments = false
    var hasFetchedUserPosts = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        PFMember.registerSubclass()
        PFNFLTeam.registerSubclass()
        PFPost.registerSubclass()
        PFComment.registerSubclass()
        PFEvent.registerSubclass()
        PFNotification.registerSubclass()
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        // Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("dKZqBjSRUJV3H9QU2aIqLQFX5dMsoSBT1rBGjPoF",
            clientKey: "wV3wBuIFJN8sCI0AdjiA9vvMkU9Ms2J9oCXNs6W0")
        
        PFUser.enableAutomaticUser()
        print("launching with user \(PFMember.currentUser())")

        // [Optional] Track statistics around application opens.
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
        UIView.my_appearanceWhenContainedIn(UIAlertController).tintColor = Constants.GLOBAL_TINT

        return true
    }
    
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
                            }
                        } else {
                            print("Error: \(error!) \(error!.userInfo)")
                        }
                    })
                }
            }
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
        self.hasFetchedUserComments = false
        self.hasFetchedUserPosts = false
        
        if let user = PFMember.currentUser() {
            if let query = PFPost.queryForUserPosts(user) {
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    self.hasFetchedUserPosts = true
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) user posts.")
                        if let objects = objects as? [PFPost] {
                            for object in objects {
                                if let objectId = object.objectId {
                                    self.setContentKarma(objectId, votes: object.votes)
                                }
                            }
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                    self.updateContentKarma()
                }
            }
            if let query = PFComment.queryForUserComments(user) {
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    self.hasFetchedUserComments = true
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) user comments.")
                        if let objects = objects as? [PFComment] {
                            for object in objects {
                                if let objectId = object.objectId {
                                    self.setContentKarma(objectId, votes: object.votes)
                                }
                            }
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                    self.updateContentKarma()
                }
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "io.arborapps.SportsYakCoreData" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("CoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SportsYakCoreData.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    // #pragma mark - Demo
    
    func setContentKarma(objectId: String, votes: Int) {
        
        let fReq: NSFetchRequest = NSFetchRequest(entityName: "ContentKarma")
        
        fReq.predicate = NSPredicate(format:"objectId == \(objectId) ")
        fReq.returnsObjectsAsFaults = false
        
        if let moc = self.managedObjectContext {
            do {
                let result = try moc.executeFetchRequest(fReq)
                if let contentKarma = result.first as? ContentKarma {
                    if (contentKarma.votes != votes) {
                        NSLog("Updated New ContentKarma for \(objectId) (\(votes))")
                        contentKarma.votes = votes
                        self.saveContext()
                    }
                    
                }
                else {
                    let contentKarma: ContentKarma = NSEntityDescription.insertNewObjectForEntityForName("ContentKarma", inManagedObjectContext: moc) as! ContentKarma
                    contentKarma.objectId = objectId
                    contentKarma.votes = votes
                    NSLog("Inserted New ContentKarma for \(objectId) (\(votes))")
                    self.saveContext()
                }
            } catch _ as NSError {
            }
        }

    }
    
    func updateContentKarma() {
        if (self.hasFetchedUserComments && self.hasFetchedUserPosts) {
            let fReq: NSFetchRequest = NSFetchRequest(entityName: "ContentKarma")
            fReq.returnsObjectsAsFaults = false
            
            if let moc = self.managedObjectContext {
                do {
                    let result = try moc.executeFetchRequest(fReq)
                    var votes = 0
                    for contentKarma : ContentKarma in result as! [ContentKarma] {
                        votes += contentKarma.votes
                    }
                    
                    if let user = PFMember.currentUser() {
                        user.resetContentKarma(votes)
                    }
                } catch _ as NSError {
                }
            }
        }
        
    }
    
}

