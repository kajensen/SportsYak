//
//  CoreData.swift
//  SportsYak
//
//  Created by Kurt Jensen on 9/28/15.
//  Copyright © 2015 Arbor Apps. All rights reserved.
//

import UIKit
import CoreData
import Bolts

class CoreData: NSObject {
    
    static let stack = CoreData()
    var hasFetchedUserComments = false
    var hasFetchedUserPosts = false
    
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
        fReq.predicate = NSPredicate(format: "objectId = %s", argumentArray: [objectId])
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
            } catch let error as NSError {
                print(error)
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
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    func syncKarma() {
        self.hasFetchedUserComments = false
        self.hasFetchedUserPosts = false
        
        if let user = PFMember.currentUser() {
            if let query = PFPost.queryForUserPosts(user) {
                query.findObjectsInBackgroundWithBlock({
                    (objects, error) -> Void in
                    self.hasFetchedUserPosts = true
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
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
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updateContentKarma()
                        }
                    }
                })
            }
            if let query = PFComment.queryForUserComments(user) {
                query.findObjectsInBackgroundWithBlock ({
                    (objects, error) -> Void in
                    self.hasFetchedUserComments = true
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
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
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updateContentKarma()
                        }
                    }
                })
            }
        }
    }
}
