//
//  ViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

class ViewController: VC, GoogleAPICompatible {
    
    var gIDSignInProxy = GIDSignInProxyObject()
    var calendarProxy = CoreDataProxy<Calendar>()
    var eventProxy = CoreDataProxy<Event>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        
        gIDSignInProxy.configure(with: self)
        
        let calendarProxyConfig = ProxyConfigWithDelegate(delegate: self, sortDescriptors: [("summary", true)])
        
        let eventProxyConfig = ProxyConfigWithTableView(tableView: tableView, sortDescriptors: [("summary", true)]) { (object, indexPath) -> UITableViewCell in
            if let event = object as? Event {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
                cell.textLabel?.text = event.summary
                cell.detailTextLabel?.text = event.createdAt?.shortString
//                cell.contentView.backgroundColor = UIColor(hexString: calendar.backgroundColor.stringValue)
//                cell.textLabel?.textColor = UIColor(hexString: calendar.foregroundColor.stringValue)
                return cell
            }
            return UITableViewCell()
        }
        
        calendarProxy.configure(config: calendarProxyConfig)
        eventProxy.configure(config: eventProxyConfig)
        
        CalendarList.get(for: self)
        //Calendar.all(for: self)
    }

}

extension ViewController: CoreDataProxyDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case.insert:
            guard let calendar = anObject as? Calendar else { return }
            Event.all(calendarId: calendar.id!, for: self)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
