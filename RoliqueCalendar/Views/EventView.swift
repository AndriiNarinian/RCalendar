//
//  EventView.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/4/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class EventView: NibLoadingView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backView: UIView!
    
    var event: Event?
    
    func update(with event: Event) {
        
        self.event = event
        
//        label1.text = event.summary
//        label2.text = Formatters.dateAndTime.string(from: (event.start?.dateToUse ?? NSDate()) as Date)
//        label3.text = Formatters.dateAndTime.string(from: (event.end?.dateToUse ?? NSDate()) as Date)
//        label4.text = event.organizer?.displayName
//        label5.text = "attendees: \(event.attendees?.count ?? 0)"
//        label6.text = (event.reminders?.overrides?.array as? [Reminder])?.map { "\($0.method.stringValue) in \($0.minutes) minutes" }.reduce(with: ", ")
        if let calendar = event.calendar {
            backView.backgroundColor = UIColor(hexString: calendar.backgroundColor.stringValue)
        } else {
            backView.backgroundColor = .darkGray
        }
        backView.layer.cornerRadius = 2.0

    }
    
}



func == (lhs: EventView, rhs: EventView) -> Bool {
    return lhs.event == rhs.event
}
