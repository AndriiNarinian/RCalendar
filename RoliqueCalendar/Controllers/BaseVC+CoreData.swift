//
//  BaseVC+CoreData.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/27/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

protocol CoreDataProxy {
    var managedObjectContext: NSManagedObjectContext { get }
    func configure(with tableView: UITableView)
}

extension CoreDataProxy {
    var managedObjectContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
    }
}

class CoreDataProxyObject: NSObject, CoreDataProxy, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    var tableView: UITableView?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    override init() {
        super.init()
        self.fetchedResultsController = initializeFetchedResultsController()
    }

    func configure(with tableView: UITableView) {
        self.tableView = tableView
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    fileprivate func initializeFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarExtended")
        let summarySort = NSSortDescriptor(key: "summary", ascending: true)
        let idSort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [summarySort, idSort]
        
        let fetchedResultsController = NSFetchedResultsController(
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
        
        return fetchedResultsController
    }
}

protocol CoreDataTableCompatibleVC {
    var coreDataProxy: CoreDataProxyObject { get }
    func existingCalendarExtended(with id: String?) -> CalendarExtended?
    func save(_ calendar: GCalendarExtended)
}

extension CoreDataTableCompatibleVC {
    var managedObjectContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
    }
    
    func existingCalendarExtended(with id: String?) -> CalendarExtended? {
        guard let id = id else { return nil }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarExtended")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.includesSubentities = false
        
        var managedExtendedCalendar: CalendarExtended?
        
        do {
            managedExtendedCalendar = try self.managedObjectContext.fetch(fetchRequest).first as? CalendarExtended
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return managedExtendedCalendar
    }
    
    func save(_ calendar: GCalendarExtended) {
        var calendarMO = existingCalendarExtended(with: calendar.id)
        
        if calendarMO == nil {
            let entity = NSEntityDescription.entity(forEntityName: "CalendarExtended", in: self.managedObjectContext)
            
            calendarMO = CalendarExtended(entity: entity!, insertInto: self.managedObjectContext)
        }
        calendarMO?.id = calendar.id
        calendarMO?.etag = calendar.etag
        calendarMO?.summary = calendar.summary
        calendarMO?.descr = calendar.description
        calendarMO?.backgroundColor = calendar.backgroundColor
        calendarMO?.foregroundColor = calendar.foregroundColor
        
        do {
            try managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }
}

extension CoreDataProxyObject {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let extendedCalendar = fetchedResultsController?.object(at: indexPath) as! CalendarExtended
        cell.textLabel?.text = extendedCalendar.summary
        cell.detailTextLabel?.text = extendedCalendar.descr
        cell.contentView.backgroundColor = UIColor(hexString: extendedCalendar.backgroundColor.string())
        cell.textLabel?.textColor = UIColor(hexString: extendedCalendar.foregroundColor.string())
        return cell
    }
}

extension CoreDataProxyObject {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // let extendedCalendar = fetchedResultsController?.object(at: indexPath)
    }
}

extension CoreDataProxyObject {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView?.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView?.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView?.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
}
