//
//  CoreDataProxy.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/28/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

protocol ProxyCompatible {
    associatedtype ResultType: NSFetchRequestResult
    
    var coreDataProxy: CoreDataProxy<ResultType> { get }
}

typealias SortDescriptor = (String, Bool)
typealias TableViewCellConfigurationHandler = (NSFetchRequestResult?, IndexPath) -> UITableViewCell
enum ProxyConfigMode { case withTableView, withDelegate }

protocol ProxyConfig {
    var mode: ProxyConfigMode { get set }
    var sortDescriptors: [SortDescriptor] { get set }
    var tableView: UITableView? { get }
    var tableViewCellConfigurationHandler: TableViewCellConfigurationHandler? { get }
    var delegate: CoreDataProxyDelegate? { get }
    var updateMode: ProxyConfigWithTableViewTableViewUpdateMode { get }
}

extension ProxyConfig {
    var tableView: UITableView? { return nil }
    var tableViewCellConfigurationHandler: TableViewCellConfigurationHandler? { return nil }
    var delegate: CoreDataProxyDelegate? { return nil }
    var updateMode: ProxyConfigWithTableViewTableViewUpdateMode { return .rowInsertion }
}

enum ProxyConfigWithTableViewTableViewUpdateMode { case rowInsertion, tableViewReload }

struct ProxyConfigWithTableView: ProxyConfig {
    var mode: ProxyConfigMode
    var sortDescriptors: [SortDescriptor]
    var tableViewCellConfigurationHandler: TableViewCellConfigurationHandler?
    var tableView: UITableView?
    var updateMode: ProxyConfigWithTableViewTableViewUpdateMode = .rowInsertion
    
    init (tableView: UITableView,
          sortDescriptors: [SortDescriptor],
          updateMode: ProxyConfigWithTableViewTableViewUpdateMode = .rowInsertion,
          tableViewCellConfigurationHandler: TableViewCellConfigurationHandler?) {
        self.tableView = tableView
        self.sortDescriptors = sortDescriptors
        self.tableViewCellConfigurationHandler = tableViewCellConfigurationHandler
        self.mode = .withTableView
        self.updateMode = updateMode
    }
}

struct ProxyConfigWithDelegate: ProxyConfig {
    var mode: ProxyConfigMode
    var sortDescriptors: [SortDescriptor]
    var delegate: CoreDataProxyDelegate?
    
    init (delegate: CoreDataProxyDelegate, sortDescriptors: [SortDescriptor]) {
        self.sortDescriptors = sortDescriptors
        self.delegate = delegate
        self.mode = .withDelegate
    }
}

protocol CoreDataProxyDelegate: class {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
}

class CoreDataProxy<ResultType: NSFetchRequestResult>: NSObject, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var tableView: UITableView?
    var delegate: CoreDataProxyDelegate?
    var config: ProxyConfig?
    var fetchedResultsController: NSFetchedResultsController<ResultType>?
    
    func configure(config: ProxyConfig) {
        switch config.mode {
        case .withTableView:
            self.tableView = config.tableView
            self.config = config
            self.fetchedResultsController = initializeFetchedResultsController()
            self.tableView?.delegate = self
            self.tableView?.dataSource = self
        case .withDelegate:
            self.config = config
            self.delegate = config.delegate
            self.fetchedResultsController = initializeFetchedResultsController()
        }
        
    }
    
    fileprivate func initializeFetchedResultsController() -> NSFetchedResultsController<ResultType>? {
        guard let config = config else { return nil }
        let request = NSFetchRequest<ResultType>(entityName: String(describing: ResultType.self))
        request.sortDescriptors = config.sortDescriptors.map { NSSortDescriptor(key: $0.0, ascending: $0.1) }
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreData.mainContext,
            sectionNameKeyPath: config.mode == .withTableView ? #keyPath(Event.dayString) : nil,
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController?.sections?[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = fetchedResultsController?.object(at: indexPath)
        if let handler = config?.tableViewCellConfigurationHandler {
            return handler(object, indexPath)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // let extendedCalendar = fetchedResultsController?.object(at: indexPath)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let config = config else { return }
        DispatchQueue.main.async {
            switch config.mode {
            case .withDelegate: config.delegate?.controllerWillChangeContent(controller)
            case .withTableView:
                switch config.updateMode {
                case .rowInsertion: self.tableView?.beginUpdates()
                default: break
                }
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard let config = config else { return }
        DispatchQueue.main.async {
            switch config.mode {
            case .withDelegate: config.delegate?.controller(controller, didChange: sectionInfo, atSectionIndex: sectionIndex, for: type)
            case .withTableView:
                switch config.updateMode {
                case .rowInsertion:
                    switch type {
                    case .insert:
                        self.tableView?.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                    case .delete:
                        self.tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                    case .move:
                        break
                    case .update:
                        break
                    }
                default: break
                }
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        return
        guard let config = config else { return }
        DispatchQueue.main.async {
            switch config.mode {
            case .withDelegate: config.delegate?.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
            case .withTableView:
                switch config.updateMode {
                case .rowInsertion:
                    switch type {
                    case .insert:
                        self.tableView?.insertRows(at: [newIndexPath!], with: .fade)
                    case .delete:
                        self.tableView?.deleteRows(at: [indexPath!], with: .fade)
                    case .move:
                        self.tableView?.moveRow(at: indexPath!, to: newIndexPath!)
                    case .update:
                        self.tableView?.reloadRows(at: [indexPath!], with: .fade)
                    }
                default: break
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let config = config else { return }
        DispatchQueue.main.async {
            switch config.mode {
            case .withDelegate: config.delegate?.controllerDidChangeContent(controller)
            case .withTableView:
                switch config.updateMode {
                case .rowInsertion:
                    self.tableView?.endUpdates()
                case .tableViewReload:
                    config.tableView?.reloadData()
                }
            }
        }
    }
}