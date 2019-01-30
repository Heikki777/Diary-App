//
//  DataSource.swift
//  Diary App
//
//  Created by Heikki Hämälistö on 19/10/2017.
//  Copyright © 2017 Heikki Hämälistö. All rights reserved.
//

import UIKit
import CoreData
import Photos

class DataSource: NSObject, UITableViewDataSource{
    private let tableView: UITableView
    private let context: NSManagedObjectContext
    private weak var viewController: UIViewController?
    
    var filteredEntries: [JournalEntry]?
    
    var searchText: String?{
        didSet{
            if let searchText = searchText{
                if !searchText.isEmpty{
                    do{
                        self.filteredEntries = try fetchedResultsController.managedObjectContext.fetch(JournalEntry.fetchRequest(text: searchText))
                        self.tableView.reloadData()
                    }
                    catch let error{
                        print(error.localizedDescription)
                    }
                }
                else{
                    filteredEntries = nil
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<JournalEntry> = {
        return DiaryFetchedResultsController(managedObjectContext: self.context, tableView: self.tableView)
    }()
    
    init(tableView: UITableView, context: NSManagedObjectContext, viewController: UIViewController){
        self.tableView = tableView
        self.context = context
        self.viewController = viewController
    }
    
    func object(at indexPath: IndexPath) -> JournalEntry{
        if let filteredEntries = self.filteredEntries{
            return filteredEntries[indexPath.row]
        }
        return fetchedResultsController.object(at: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else{
            return 0
        }
        
        if let filteredEntries = self.filteredEntries{
            return filteredEntries.count
        }
        
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! JournalEntryCell
        
        return configureCell(cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = fetchedResultsController.sections?[section].name
        return title
    }
    
    private func configureCell(_ cell: JournalEntryCell, at indexPath: IndexPath) -> JournalEntryCell{
        let entry = self.object(at: indexPath)
        
        cell.entryDateLabel.text = entry.createdOnDate.toDiaryDateFormat()
        cell.entryTextLabel.text = entry.text
        
        if let location = entry.location{
            cell.locationLabel.text = location
        }
        
        if let imageData = entry.imageData{
            if let image = UIImage.init(data: imageData){
                cell.entryImageView.image = image
            }
        }
        
        var dayRating: DayRating?
        if let dayRatingString = entry.dayRating{
            dayRating = DayRating(rawValue: dayRatingString)
        }
        cell.dayRatingView.rating = dayRating
        cell.dayRatingView.isHidden = dayRating == nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let entry = fetchedResultsController.object(at: indexPath)
        context.delete(entry)
        context.saveChanges{
            if let viewController = viewController{
                Alert.showSaveDataError(context: viewController)
            }
        }
    }
}
