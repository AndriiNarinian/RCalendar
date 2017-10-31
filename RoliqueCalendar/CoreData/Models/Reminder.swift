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
        let reminder = Dealer<Reminder>.inserted
        reminder.method = dict["method"].string
        reminder.minutes = dict["minutes"].int64Value
        return reminder
    }
    
    @discardableResult static func insertBack(from dict: [String: Any]) -> Reminder {
        let reminder = Dealer<Reminder>.inserted
        reminder.method = dict["method"].string
        reminder.minutes = dict["minutes"].int64Value
        return reminder
    }
}
