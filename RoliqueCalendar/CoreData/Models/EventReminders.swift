//
//  EventReminders.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension EventReminders {
    @discardableResult static func insert(from dict: [String: Any]) -> EventReminders {
        let reminders = EventReminders(context: CoreData.context)
        reminders.useDefault = dict["type"].boolValue
        reminders.overrides = dict["overrides"].maybeInsertDictArray { Reminder.insert(from: $0.dictValue) }
        
        return reminders
    }
}
