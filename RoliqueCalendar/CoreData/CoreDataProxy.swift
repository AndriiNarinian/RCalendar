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
    var proxyConfigTableViewDelegate: ProxyConfigWithTableViewDelegate? { get }
    var delegate: CoreDataProxyDelegate? { get }
    var updateMode: ProxyConfigWithTableViewTableViewUpdateMode { get }
}

extension ProxyConfig {
    var tableView: UITableView? { return nil }
    var tableViewCellConfigurationHandler: TableViewCellConfigurationHandler? { return nil }
    var proxyConfigTableViewDelegate: ProxyConfigWithTableViewDelegate? { return nil }
    var delegate: CoreDataProxyDelegate? { return nil }
    var updateMode: ProxyConfigWithTableViewTableViewUpdateMode { return .rowInsertion }
}

enum ProxyConfigWithTableViewTableViewUpdateMode { case rowInsertion, tableViewReload }

protocol ProxyConfigWithTableViewDelegate: class {
    func willDisplayLastRow()
    func willDisplayFirstRow()
    func didUpdate()
    func willUpdate()
    func didSelectRow(at indexPath: IndexPath)
}

struct ProxyConfigWithTableView: ProxyConfig {
    var mode: ProxyConfigMode
    var sortDescriptors: [SortDescriptor]
    var tableViewCellConfigurationHandler: TableViewCellConfigurationHandler?
    var tableView: UITableView?
    var updateMode: ProxyConfigWithTableViewTableViewUpdateMode = .rowInsertion
    weak var proxyConfigTableViewDelegate: ProxyConfigWithTableViewDelegate?
    
    init (tableView: UITableView,
          sortDescriptors: [SortDescriptor],
          updateMode: ProxyConfigWithTableViewTableViewUpdateMode = .rowInsertion,
          proxyConfigTableViewDelegate: ProxyConfigWithTableViewDelegate? = nil,
          tableViewCellConfigurationHandler: TableViewCellConfigurationHandler?) {
        self.tableView = tableView
        self.sortDescriptors = sortDescriptors
        self.tableViewCellConfigurationHandler = tableViewCellConfigurationHandler
        self.mode = .withTableView
        self.updateMode = updateMode
        self.proxyConfigTableViewDelegate = proxyConfigTableViewDelegate
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
    
    let kHeaderHeight: CGFloat = 50
    
    var tableView: UITableView?
    var delegate: CoreDataProxyDelegate?
    var config: ProxyConfig?
    var fetchedResultsController: NSFetchedResultsController<ResultType>?
    var lastIndexPath: IndexPath?
    
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
            sectionNameKeyPath: config.mode == .withTableView ? #keyPath(Event.monthString) : nil,
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
        //guard sectionInfoContainsToday(sectionInfo) else { return sectionInfo.numberOfObjects }
        return sectionInfo.numberOfObjects// + 1
    }
 
    fileprivate func sectionInfoContainsToday(_ sectionInfo: NSFetchedResultsSectionInfo) -> Bool {
        return (sectionInfo.objects as? [Day])?.map { (($0.date ?? NSDate()) as Date).withoutTime }.contains( Date().withoutTime ) ?? false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let indexPaths = tableView?.indexPathsForVisibleRows else { return }
        indexPaths.forEach {
            guard let cell = tableView?.cellForRow(at: $0) as? DayTableViewCell, let rect = tableView?.rectForRow(at: $0) else { return }
            let converted = tableView?.convert(rect, to: tableView?.superview)
            let rec = CGRect(x: converted?.origin.x ?? 0, y: (converted?.origin.y ?? 0) - 20 - kHeaderHeight, width: converted?.width ?? 0, height: converted?.height ?? 0)
            if let day = fetchedResultsController?.object(at: $0) as? Day {
                if day.timeStamp == cell.day?.timeStamp {
                    cell.parentTableViewDidScroll(tableView!, rect: rec, with: day)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let day = fetchedResultsController?.object(at: indexPath) as? Day
        let tableviewHeight = CGFloat(day?.events?.count ?? 0) * 70
        return tableviewHeight > 0 ? tableviewHeight + 16 : 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let day = (fetchedResultsController?.object(at: indexPath) as? Day)
        if let lastIndexPath = lastIndexPath {
            let currentDate = day?.date as Date?
            
            if lastIndexPath < indexPath {
                // going down
                if let current = currentDate, let max = RCalendar.main.bounds?.max {
                    if current > max {
                        config?.proxyConfigTableViewDelegate?.willDisplayLastRow()
                    }
                }
            } else {
                // going up
                if let current = currentDate, let min = RCalendar.main.bounds?.min {
                    if current < min {
                        config?.proxyConfigTableViewDelegate?.willDisplayFirstRow()
                    }
                }
            }
        }
        lastIndexPath = indexPath
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                config?.proxyConfigTableViewDelegate?.willDisplayFirstRow()
            }
        }
        if indexPath.section == (fetchedResultsController?.sections?.count ?? 1) - 1 {
            let sectionInfo = fetchedResultsController?.sections?[indexPath.section]
            if indexPath.row == (sectionInfo?.numberOfObjects ?? 1) - 1 {
                config?.proxyConfigTableViewDelegate?.willDisplayLastRow()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = EventSectionHeaderView(frame: .zero)
        guard let date = Formatters.monthAndYear.date(from: fetchedResultsController?.sections?[section].name ?? "") else { return nil }
        header.monthLabel.text = Formatters.monthAndYear.string(from: date)

        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = fetchedResultsController?.object(at: indexPath)
        if let handler = config?.tableViewCellConfigurationHandler {
            let cell = handler(object, indexPath)
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        config?.proxyConfigTableViewDelegate?.didSelectRow(at: indexPath)
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
                    config.proxyConfigTableViewDelegate?.willUpdate()
                    config.tableView?.reloadData()
                    config.proxyConfigTableViewDelegate?.didUpdate()
                }
            }
        }
    }
}
