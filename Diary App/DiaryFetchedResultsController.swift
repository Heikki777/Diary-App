//
//  DiaryFetchedResultsController.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 18/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit
import CoreData

class DiaryFetchedResultsController: NSFetchedResultsController<JournalEntry>, NSFetchedResultsControllerDelegate{
    
    private let tableView: UITableView
    
    init(managedObjectContext: NSManagedObjectContext, tableView: UITableView){
        self.tableView = tableView
        super.init(fetchRequest: JournalEntry.fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: "formattedMonthYear", cacheName: nil)
        
        self.delegate = self
        
        tryFetch()
    }
    
    func tryFetch(){
        do{
            try performFetch()
        }
        catch{
            print("Unresolved error: \(error.localizedDescription)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break;
        }

    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
            
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .update, .move:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        
        }
    }
    
    // MARK: FetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
