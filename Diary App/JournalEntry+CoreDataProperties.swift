//
//  JournalEntry+CoreDataProperties.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 18/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//
//

import Foundation
import CoreData

extension JournalEntry {
    
    static let maxLength = 200

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntry> {
        let request = NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
        request.sortDescriptors = [NSSortDescriptor(key: "createdOnDate", ascending: false)]
        
        return request
    }
    
    @nonobjc public class func fetchRequest(text: String) -> NSFetchRequest<JournalEntry> {
        let request = NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
        request.predicate = NSPredicate(format: "text contains[cd] %@", text)
        request.sortDescriptors = [NSSortDescriptor(key: "createdOnDate", ascending: false)]
     
        return request
    }

    @NSManaged public var text: String
    @NSManaged public var createdOnDate: Date
    @NSManaged public var lastUpdatedDate: Date
    @NSManaged public var location: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var dayRating: String?
    
    @objc var formattedMonthYear: String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self.createdOnDate)
    }

}
