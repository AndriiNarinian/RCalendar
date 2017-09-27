//
//  GEventReminders.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct GEventReminders: GModelType {
    var useDefault: Bool?
    var overrides: [GReminder]?
    
    init?(dict: [String: Any?]?) {
        guard let dict = dict else { return nil }
        useDefault = dict["useDefault"] as? Bool
        overrides = (dict["overrides"] as? [[String: Any]])?.flatMap { GReminder(dict: $0) }
    }
    
    var encoded: [String: Any?] {
        return [
            "useDefault": useDefault,
            "overrides": overrides?.map { $0.encoded }
        ]
    }
}
