//
//  Reminder.swift
//  ICS4UTutorialTest
//
//  Created by Eric Qiu on 2016-06-11.
//  Copyright © 2016 Eric Qiu. All rights reserved.
//

import Foundation
import UIKit

class Reminder: NSObject, NSCoding {
  
    
    
    // Properties
    var notification: UILocalNotification

    
    // Archive Paths for Persistent Data
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("reminders")     
    // enum for property types
    struct PropertyKey {

        static let notificationKey = "notification"
    }
    
    // Initializer
    init( notification: UILocalNotification) {

        self.notification = notification
        
        super.init()
    }
    
    // Destructor
    deinit {
        // cancel notification
        UIApplication.shared.cancelLocalNotification(self.notification)
    }
    
    // NSCoding
    
    func encode(with coder: NSCoder) {
  
        coder.encode(notification, forKey: PropertyKey.notificationKey)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        //let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Meal, use conditional cast.
        //let time = aDecoder.decodeObject(forKey: PropertyKey.timeKey) as! NSDate
        
        let notification = aDecoder.decodeObject(forKey: PropertyKey.notificationKey) as! UILocalNotification
        
        // Must call designated initializer.
        self.init(notification: notification)
    }
}
