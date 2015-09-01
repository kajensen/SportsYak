//
//  ContentKarma.swift
//  
//
//  Created by Kurt Jensen on 8/31/15.
//
//

import Foundation
import CoreData

class ContentKarma: NSManagedObject {

    @NSManaged var objectId: String
    @NSManaged var votes: Int

}
