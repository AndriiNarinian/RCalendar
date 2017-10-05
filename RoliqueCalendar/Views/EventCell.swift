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
    @IBOutlet weak var backView: UIView!
    
    func update(with event: Event?) {
        titleLabel.text = event?.summary
        let start = Formatters.hoursAndMinutes.string(from: (event?.start?.dateToUse ?? NSDate()) as Date)
        let end = Formatters.hoursAndMinutes.string(from: (event?.end?.dateToUse ?? NSDate()) as Date)
        timeLabel.text = start == end ? "" : "\(start) - \(end)"
        backView.backgroundColor = UIColor(hexString: event?.calendarColor ?? "")
        backView.layer.cornerRadius = 4.0
    }
}
