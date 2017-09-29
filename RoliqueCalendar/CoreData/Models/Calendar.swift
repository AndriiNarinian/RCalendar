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
            Dealer<Calendar>.updateWith(array: dicts, insertion: insert(from:))
        }
    }
    
    @discardableResult static func insert(from dict: [String: Any]) -> Calendar {
        let calendar = Calendar(context: CoreData.context)
        calendar.kind = dict["kind"] as? String
        calendar.etag = dict["etag"].string
        calendar.id = dict["id"].string
        calendar.summary = dict["summary"].string
        calendar.descr = dict["description"].string
        calendar.location = dict["location"].string
        calendar.timeZone = dict["timeZone"].string
        calendar.colorId = dict["colorId"].string
        calendar.backgroundColor = dict["backgroundColor"].string
        calendar.foregroundColor = dict["foregroundColor"].string
        calendar.isSelected = dict["selected"].boolValue
        calendar.accessRole = dict["accessRole"].string
        calendar.defaultReminders = dict["defaultReminders"].maybeInsertDictArray { Reminder.insert(from: $0.dictValue) }
        calendar.notificationSettings = dict["notificationSettings"].maybeInsertDictObject { NotificationSettings.insert(from: $0.dictValue) }
        calendar.isPrimary = dict["primary"].boolValue
        calendar.wasDeleted = dict["deleted"].boolValue
        
        return calendar
    }
}
