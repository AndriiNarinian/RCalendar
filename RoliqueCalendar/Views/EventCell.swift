//
//  EventCell.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/5/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calendarsLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    func update(with event: Event?) {
        titleLabel.text = event?.summary
        let start = Formatters.hoursAndMinutes.string(from: (event?.start?.dateToUse ?? NSDate()) as Date)
        let end = Formatters.hoursAndMinutes.string(from: (event?.end?.dateToUse ?? NSDate()) as Date)
        timeLabel.text = start == end ? "" : "\(start) - \(end)"
        let calendarColorHex = event?.calendars.first?.colorHex
        backView.backgroundColor = calendarColorHex != nil ? UIColor(hexString: calendarColorHex!) : .darkGray
        backView.layer.cornerRadius = 4.0
        calendarsLabel.text = String(describing: event?.calendars.map { $0.name } ?? [""] )
        
        //[RRULE:FREQ=YEARLY]
        //[RRULE:FREQ=WEEKLY;BYDAY=TH]
        //[EXDATE;TZID=Europe/Kiev:20170801T103000,20170808T103000,20170810T103000,20170815T103000, RRULE:FREQ=WEEKLY;UNTIL=20170821T205959Z;BYDAY=TU,TH]
        //[RRULE:FREQ=WEEKLY;UNTIL=20170730T205959Z;BYDAY=MO,TU,WE,TH,FR]
        //[EXDATE;TZID=Europe/Kiev:20160916T170000,20160923T170000,20160930T170000,20161007T170000,20161014T170000, RRULE:FREQ=WEEKLY;UNTIL=20161021T135959Z;INTERVAL=1;BYDAY=FR]
        //[EXDATE;VALUE=DATE:20160824, RRULE:FREQ=YEARLY]
        
        /*List of RRULE, EXRULE, RDATE and EXDATE lines for a recurring event, as specified in RFC5545. Note that DTSTART and DTEND lines are not allowed in this field; event start and end times are specified in the start and end fields. This field is omitted for single events or instances of recurring events.*/
    }
}
