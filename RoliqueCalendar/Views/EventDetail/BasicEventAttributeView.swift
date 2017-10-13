//
//  BasicEventAttributeView.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/10/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

enum EventAttributeViewType: Int {
    case time = 0, location = 1, reminder = 2, hangout = 3, guests = 4, guestsTable = 5, calendar = 6
    
    var icon: UIImage? {
        switch self {
        case .time: return #imageLiteral(resourceName: "time")
        case .location: return #imageLiteral(resourceName: "location")
        case .reminder: return #imageLiteral(resourceName: "reminder")
        case .hangout: return #imageLiteral(resourceName: "hangouts")
        case .guests: return #imageLiteral(resourceName: "users")
        case .guestsTable: return nil
        case .calendar: return #imageLiteral(resourceName: "calendar")
        }
    }
}

protocol EventAttributeView: class {
    var typeId: Int { get set }
    var type: EventAttributeViewType? { get set }
}

class BasicEventAttributeView: NibLoadingView, EventAttributeView {
    @IBInspectable var typeId: Int = 0 {
        didSet {
            type = EventAttributeViewType(rawValue: typeId)
        }
    }
    var type: EventAttributeViewType?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func update(with event: Event) {
        guard let type = type else { return }
        iconImageView.image = type.icon
        switch type {
        case .time:
            let start = Formatters.hoursAndMinutes.string(from: (event.start?.dateToUse ?? NSDate()) as Date)
            let end = Formatters.hoursAndMinutes.string(from: (event.end?.dateToUse ?? NSDate()) as Date)
            titleLabel.text = Formatters.dayAndMonthAndYear.string(from: (event.start?.dateToUse ?? NSDate()) as Date)
            subtitleLabel.text = (start == end ? "" : "\(start) - \(end)")
        case .reminder:
            let reminders = Unwrap<Reminder>.arrayValueFromSet(event.reminders?.overrides)
            guard reminders.count > 0 else {
                titleLabel.text = ""
                subtitleLabel.text = ""
                
                return }
            titleLabel.text = event.reminders?.useDefault ?? false ? "default" : "\(reminders.map { $0.method })"
            subtitleLabel.text = event.reminders?.useDefault ?? false ? "default" : "\(reminders.map { "\($0.minutes) minutes before" })"
        case .hangout:
            let url = URL(string: event.hangoutLink ?? "")
            titleLabel.text = url?.lastPathComponent
            subtitleLabel.text = "Join Hangout"
        case .location:
            titleLabel.text = event.location
            subtitleLabel.text = ""
        case .guests:
            titleLabel.text = "\(event.sortedGuests.count) guests"
            let acceptedCount = event.sortedGuests.filter({ $0.responseStatus == "accepted" }).count
            subtitleLabel.text = "\(acceptedCount) accepted, \(event.sortedGuests.count - acceptedCount) awaiting"
        case .calendar:
            titleLabel.text = event.calendars.first?.name
            subtitleLabel.text = ""
        case .guestsTable: break

        }
    }
}
