//
//  CoreDataStack.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 18/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack{
    
    var managedObjectContext: NSManagedObjectContext{
        get{
            let container = self.persistentContainer
            return container.viewContext
        }
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Diary")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError?{
                print("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
}

extension NSManagedObjectContext{
    func saveChanges(errorHandler: () -> Void){
        if self.hasChanges{
            do{
                try save()
            }
            catch{
                errorHandler()
            }
        }
    }
}
