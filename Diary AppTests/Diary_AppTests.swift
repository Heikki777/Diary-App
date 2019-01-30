//
//  Diary_AppTests.swift
//  Diary AppTests
//
//  Created by Heikki Hämälistö on 23/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import XCTest
import CoreData
@testable import Diary_App

class Diary_AppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCoreDataItemInsertion() {
        let managedObjectContext = CoreDataStack().managedObjectContext
        
        // The number of inserted objects should equal to zero
        XCTAssert(managedObjectContext.insertedObjects.count == 0)

        // Insert an object
        guard let entry = NSEntityDescription.insertNewObject(forEntityName: "JournalEntry", into: managedObjectContext) as? JournalEntry else{
            fatalError()
        }
        
        entry.text = "Test"
        entry.createdOnDate = Date.init()
        entry.lastUpdatedDate = Date.init()
        entry.location = "Test location"
        entry.imageData = nil
        
        // .. now it should equal to one.
        XCTAssert(managedObjectContext.insertedObjects.count == 1)
    }
    
    
    func testCoreDataItemDeletion(){
        let managedObjectContext = CoreDataStack().managedObjectContext
        guard let entry = NSEntityDescription.insertNewObject(forEntityName: "JournalEntry", into: managedObjectContext) as? JournalEntry else{
            fatalError()
        }
        
        entry.text = "Test"
        entry.createdOnDate = Date.init()
        entry.lastUpdatedDate = Date.init()
        entry.location = "Test location"
        entry.imageData = nil
        
        XCTAssert(managedObjectContext.insertedObjects.count == 1)
        
        do{
            try managedObjectContext.save()
        }
        catch let error{
            print(error.localizedDescription)
        }
        
        managedObjectContext.delete(entry)
        XCTAssert(managedObjectContext.deletedObjects.count == 1)
    }
    
    func testCoreDataItemUpdate(){
        let managedObjectContext = CoreDataStack().managedObjectContext
        guard let entry = NSEntityDescription.insertNewObject(forEntityName: "JournalEntry", into: managedObjectContext) as? JournalEntry else{
            fatalError("Could not create entry")
        }
        
        entry.text = "Test"
        entry.createdOnDate = Date.init()
        entry.lastUpdatedDate = Date.init()
        entry.location = "Test location"
        entry.imageData = nil
        
        do{
            try managedObjectContext.save()
        }
        catch let error{
            print(error.localizedDescription)
        }
        
        XCTAssert(managedObjectContext.updatedObjects.count == 0)
        // Update the object
        entry.setValue("NewTextValue", forKeyPath: "text")
        XCTAssert(managedObjectContext.updatedObjects.count == 1)
        
        // Save the changes. Now the number of updated objects should be zero.
        do{
            try managedObjectContext.save()
        }
        catch let error{
            print(error.localizedDescription)
        }
        XCTAssert(managedObjectContext.updatedObjects.count == 0)
     
        // entry's lastUpdatedDate should be greater than createdOnDate
        XCTAssert(entry.createdOnDate < entry.lastUpdatedDate)
    }
}
