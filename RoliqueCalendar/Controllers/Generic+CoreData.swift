//
//  Generic+CoreData.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/28/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

protocol Proxy {
    var managedObjectContext: NSManagedObjectContext { get }
    func configure(with tableView: UITableView, config: ProxyConfig)
}

extension Proxy {
    var managedObjectContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
    }
}

typealias SortDescriptor = (String, Bool)

struct ProxyConfig {
    var entityName: String
    var sortDescriptors: [SortDescriptor]
}

class ProxyObject<ResultType>: NSObject, Proxy, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate where ResultType : NSFetchRequestResult {
    
    var tableView: UITableView?
    var config: ProxyConfig?
    var fetchedResultsController: NSFetchedResultsController<ResultType>?
    
    func configure(with tableView: UITableView, config: ProxyConfig) {
        self.tableView = tableView
        self.config = config
        self.fetchedResultsController = initializeFetchedResultsController()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    fileprivate func initializeFetchedResultsController() -> NSFetchedResultsController<ResultType>? {
        guard let config = config else { return nil }
        let request = NSFetchRequest<ResultType>(entityName: config.entityName)
        request.sortDescriptors = config.sortDescriptors.map { NSSortDescriptor(key: $0.0, ascending: $0.1) }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // let extendedCalendar = fetchedResultsController?.object(at: indexPath)
    }
    
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

protocol TableCompatibleVC {
    associatedtype ResultType: NSFetchRequestResult
    
    var coreDataProxy: ProxyObject<ResultType> { get }
    func existingObject(with id: String?) -> ResultType?
    func save(with id: String?)
}

extension TableCompatibleVC where ResultType: NSFetchRequestResult {
    var managedObjectContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
    }
    
    func existingObject(with id: String?) -> ResultType? {
        guard let id = id, let config = coreDataProxy.config else { return nil }
        let fetchRequest = NSFetchRequest<ResultType>(entityName: config.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.includesSubentities = false
        
        var managedObject: ResultType?
        
        do {
            managedObject = try self.managedObjectContext.fetch(fetchRequest).first
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return managedObject
    }
    
    func save(with id: String?) {
        var managedObject = existingObject(with: id)
        
        if managedObject == nil {
            guard let config = coreDataProxy.config else { return }
            let entity = NSEntityDescription.entity(forEntityName: config.entityName, in: self.managedObjectContext)
            
            managedObject = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext) as? ResultType
        }
        
        // TODO: implement logic for updating properties of one managed object with another
        
        do {
            try managedObjectContext.save()
        }
        catch {
            print(error)
        }
    }
}
