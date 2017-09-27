//
//  EventReminders.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct EventReminders: GModelType {
    var useDefault: Bool?
    var overrides: [Reminder]?
    
    init?(dict: [String: Any?]?) {
        guard let dict = dict else { return nil }
        useDefault = dict["useDefault"] as? Bool
        overrides = (dict["overrides"] as? [[String: Any]])?.flatMap { Reminder(dict: $0) }
    }
    
    var encoded: [String: Any?] {
        return [
            "useDefault": useDefault,
            "overrides": overrides?.map { $0.encoded }
        ]
    }
}
