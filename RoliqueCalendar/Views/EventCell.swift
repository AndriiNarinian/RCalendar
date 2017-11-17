//
//  EventCell.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/5/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

open class EventCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calendarsLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    var event: Event?
    
    func update(with event: Event?) {
        self.event = event
        titleLabel.text = event?.summary
        let start = Formatters.hoursAndMinutes.string(from: (event?.start?.dateToUse ?? Date()))
        let end = Formatters.hoursAndMinutes.string(from: (event?.end?.dateToUse ?? Date()))
        timeLabel.text = start == end ? "" : "\(start) - \(end)"
        let calendarColorHex = event?.calendars.first?.colorHex
        backView.backgroundColor = calendarColorHex != nil ? UIColor(hexString: calendarColorHex!) : .darkGray
        backView.layer.cornerRadius = 4.0
        calendarsLabel.text = event?.calendars.count == 1 ? event?.calendars.first?.name : "\(event?.calendars.count ?? 0) calendars"
    }
}
