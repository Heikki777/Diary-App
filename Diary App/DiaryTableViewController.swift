//
//  DiaryTableViewController.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 18/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit
import CoreData

class DiaryTableViewController: UITableViewController, UISearchControllerDelegate {
    
    let managedObjectContext = CoreDataStack().managedObjectContext
    let searchController = UISearchController(searchResultsController: nil)

    lazy var dataSource: DataSource = {
        return DataSource(tableView: self.tableView, context: self.managedObjectContext, viewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        
        // Set Navigation item title
        self.navigationItem.title = Date().toDiaryDateFormat()
        
        // Configure search controller
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Entries"
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.white

        navigationItem.searchController = searchController
        
        tableView.dataSource = dataSource
        
        // Register 3D Touch
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        } else {
            print("3D Touch Not Available")
        }
    }

    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newEntry"{
            let navigationController = segue.destination as! UINavigationController
            let addJournalEntryController = navigationController.topViewController as! AddJournalEntryController
            
            addJournalEntryController.managedObjectContext = self.managedObjectContext
        }
        else if segue.identifier == "showDetail"{
            guard let detailVC = segue.destination as? DetailViewController, let indexPath = tableView.indexPathForSelectedRow else{
                return
            }
            
            let entry = dataSource.object(at: indexPath)
            detailVC.entry = entry
            detailVC.context = self.managedObjectContext
        }
    }
    
    // MARK: Search
    
    func searchBarIsEmpty() -> Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool{
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All"){
        dataSource.searchText = searchText
    }
    
}

extension DiaryTableViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}

extension DiaryTableViewController: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
    }
}

extension DiaryTableViewController: UIViewControllerPreviewingDelegate {
    
    // MARK: UIViewControllerPreviewingDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else{
            return nil
        }
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        guard let detailViewController = storyboard?.instantiateViewController(
            withIdentifier: "DetailViewController") as?
            DetailViewController else { return nil }
        
        let entry = dataSource.object(at: indexPath)
        detailViewController.entry = entry
        detailViewController.context = self.managedObjectContext
        
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        previewingContext.sourceRect = cell.frame
        
        return detailViewController
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
    }
}

extension Array where Element:Equatable{
    func noDuplicates() -> [Element]{
        var uniques = [Element]()
        for element in self{
            if uniques.contains(where: { $0 == element }){
                uniques.append(element)
            }
        }
        return uniques
    }
}
