//
//  Reminder.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/28/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Reminder {
    @discardableResult static func insert(from dict: [String: Any]) -> Reminder {
        let reminder = Reminder(context: CoreData.context)
        reminder.method = dict["method"] as? String
        if let minutes = dict["minutes"] as? Int {
            reminder.minutes = Int64(minutes)
        }
        return reminder
    }
}
