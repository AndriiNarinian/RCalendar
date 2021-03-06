//
//  BasicEventAttributeView.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/10/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

enum EventAttributeViewType: Int {
    case time = 0, location = 1, reminder = 2, hangout = 3, guests = 4, guestsTable = 5, calendar = 6, calendarTable = 7
    
    var icon: UIImage? {
        switch self {
        case .time: return UIImage(named: "time", in: bundle, compatibleWith: nil)
        case .location: return UIImage(named: "location", in: bundle, compatibleWith: nil)
        case .reminder: return UIImage(named: "reminder", in: bundle, compatibleWith: nil)
        case .hangout: return UIImage(named: "hangouts", in: bundle, compatibleWith: nil)
        case .guests: return UIImage(named: "users", in: bundle, compatibleWith: nil)
        case .guestsTable: return nil
        case .calendar: return UIImage(named: "calendar", in: bundle, compatibleWith: nil)
        case .calendarTable: return nil
        }
    }
}

protocol EventAttributeView: class {
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
            let start = Formatters.hoursAndMinutes.string(from: (event.start?.dateToUse ?? Date()))
            let end = Formatters.hoursAndMinutes.string(from: (event.end?.dateToUse ?? Date()))
            titleLabel.text = Formatters.dayAndMonthAndYear.string(from: (event.start?.dateToUse ?? Date()))
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
            titleLabel.text = "calendars"
            subtitleLabel.text = event.calendars.count > 1 ? "contained in \(event.calendars.count) calendars" : ""
        case .guestsTable: break
        case .calendarTable: break
        }
    }
}
