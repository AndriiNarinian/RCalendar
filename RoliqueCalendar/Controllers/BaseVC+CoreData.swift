//
//  BaseVC+CoreData.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/27/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

protocol CoreDataTableViewOwner {
    var _tableView: UITableView { get }
}

class BaseVC: VC {
    var observeTokenCompletion: ((String) -> Void)?
    var fetchedResultsController: NSFetchedResultsController<CalendarExtendedMO>!
    
    override func viewDidLoad() {
        if let owner = self as? CoreDataTableViewOwner {
            owner._tableView.delegate = self
            owner._tableView.dataSource = self
            
        }
        
        super.viewDidLoad()
    }
}

extension BaseVC {
    var managedObjectContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<CalendarExtendedMO>(entityName: "CalendarExtended")
        let summarySort = NSSortDescriptor(key: "summary", ascending: true)
        let idSort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [summarySort, idSort]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}

extension BaseVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let extendedCalendar = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = extendedCalendar.summary
        cell.detailTextLabel?.text = extendedCalendar.descr
        cell.contentView.backgroundColor = UIColor(hexString: extendedCalendar.backgroundColor.string())
        cell.textLabel?.textColor = UIColor(hexString: extendedCalendar.foregroundColor.string())
        return cell
    }
}

extension BaseVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let extendedCalendar = fetchedResultsController.object(at: indexPath)
        Event.findAll(withCalendarId: extendedCalendar.id, owner: self) { [weak self] eventList in
            self?.displayString(eventList.dictNoNilDescription)
        }
    }
}

extension BaseVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let owner = self as? CoreDataTableViewOwner {
            owner._tableView.beginUpdates()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if let owner = self as? CoreDataTableViewOwner {
            switch type {
            case .insert:
                owner._tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                owner._tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            case .move:
                break
            case .update:
                break
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let owner = self as? CoreDataTableViewOwner {
            switch type {
            case .insert:
                owner._tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                owner._tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                owner._tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                owner._tableView.moveRow(at: indexPath!, to: newIndexPath!)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let owner = self as? CoreDataTableViewOwner {
            owner._tableView.endUpdates()
        }
    }
}
