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
        
        //tableView.rowHeight = 80
        //tableview.registerCells...
        
        gIDSignInProxy.configure(with: self)
        let calendarProxyConfig = ProxyConfigWithDelegate(delegate: self, sortDescriptors: [(#keyPath(Calendar.summary), true)])
        
        let eventProxyConfig = ProxyConfigWithTableView(tableView: tableView, sortDescriptors: [(#keyPath(Event.dayString), false)]) { [unowned self] (object, indexPath) -> UITableViewCell in
            if let event = object as? Event {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
                cell.update(with: event)
                return cell
            }
            return UITableViewCell()
        }
        
        calendarProxy.configure(config: calendarProxyConfig)
        eventProxy.configure(config: eventProxyConfig)
        
        CalendarList.fetch(for: self)
    }

}

class EventCell: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    
    func update(with event: Event) {
        label1.text = event.summary
        label2.text = Formatters.dateAndTime.string(from: (event.start?.dateToUse ?? NSDate()) as Date)
        label3.text = Formatters.dateAndTime.string(from: (event.end?.dateToUse ?? NSDate()) as Date)
        label4.text = event.organizer?.displayName
        label5.text = "attendees: \(event.attendees?.count ?? 0)"
        label6.text = (event.reminders?.overrides?.array as? [Reminder])?.map { "\($0.method.stringValue) in \($0.minutes) minutes" }.reduce(with: ", ")
        if let calendar = event.calendar {
            contentView.backgroundColor = UIColor(hexString: calendar.backgroundColor.stringValue)
        }
    }
}

// MARK: Calendar Proxy
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
