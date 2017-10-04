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
    var eventProxy = CoreDataProxy<Event>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gIDSignInProxy.configure(with: self)

        let eventProxyConfig = ProxyConfigWithTableView(tableView: tableView, sortDescriptors: [(#keyPath(Event.dayString), false)], updateMode: .tableViewReload) { [unowned self] (object, indexPath) -> UITableViewCell in
            if let event = object as? Event {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
                cell.update(with: event)
                return cell
            }
            return UITableViewCell()
        }
        eventProxy.configure(config: eventProxyConfig)
        RCalendar.main.startForCurrentUser(withOwner: self) {}
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    fileprivate func scrollToToday() {
        let sectionInfo = eventProxy.fetchedResultsController?.sections?.filter { $0.name == Formatters.gcFormatDate.string(from: Date()) }.first
        guard let object = sectionInfo?.objects?.first as? Event, let indexPath = eventProxy.fetchedResultsController?.indexPath(forObject: object) else { return }
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}

class EventCell: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var backView: UIView!
    
    func update(with event: Event) {
        label1.text = event.summary
        label2.text = Formatters.dateAndTime.string(from: (event.start?.dateToUse ?? NSDate()) as Date)
        label3.text = Formatters.dateAndTime.string(from: (event.end?.dateToUse ?? NSDate()) as Date)
        label4.text = event.organizer?.displayName
        label5.text = "attendees: \(event.attendees?.count ?? 0)"
        label6.text = (event.reminders?.overrides?.array as? [Reminder])?.map { "\($0.method.stringValue) in \($0.minutes) minutes" }.reduce(with: ", ")
        if let calendar = event.calendar {
            backView.backgroundColor = UIColor(hexString: calendar.backgroundColor.stringValue)
        } else {
            backView.backgroundColor = .darkGray
        }
        backView.layer.cornerRadius = 2.0
    }
}
