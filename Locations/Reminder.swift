//
//  Reminder.swift
//  Locations
//
//  Created by Michael Tirenin on 8/21/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var reminderMessage: String
    @NSManaged var reminderTitle: String

}
