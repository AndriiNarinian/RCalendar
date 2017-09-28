//
//  Calendar.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/28/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation
import CoreData

extension Calendar {
    static func all(for vc: GoogleAPICompatible) {
        APIHelper.getExtendedCalendars(owner: vc) { dicts in
            Dealer<CalendarExtended>.updateWith(array: dicts, insertion: insert(from:))
        }
    }
    
    @discardableResult static func insert(from dict: [String: Any]) -> CalendarExtended {
        let calendar = CalendarExtended(context: CoreData.context)
        calendar.kind = dict["kind"] as? String
        calendar.etag = dict["etag"] as? String
        calendar.id = dict["id"] as? String
        calendar.summary = dict["summary"] as? String
        calendar.descr = dict["description"] as? String
        calendar.location = dict["location"] as? String
        calendar.timeZone = dict["timeZone"] as? String
        calendar.colorId = dict["colorId"] as? String
        calendar.backgroundColor = dict["backgroundColor"] as? String
        calendar.foregroundColor = dict["foregroundColor"] as? String
        calendar.isSelected = dict["selected"] as? Bool ?? false
        calendar.accessRole = dict["accessRole"] as? String
        if let dicts = dict["defaultReminders"] as? [[String: Any]] {
            calendar.defaultReminders = NSMutableOrderedSet(array: dicts.map { Reminder.insert(from: $0) })
        }
        if let dict = dict["notificationSettings"] as? [String: Any] {
            calendar.notificationSettings =  NotificationSettings.insert(from: dict)
        }
        calendar.isPrimary = dict["primary"] as? Bool ?? false
        calendar.wasDeleted = dict["deleted"] as? Bool ?? false
        
        return calendar
    }
}
