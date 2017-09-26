//
//  NotificationSettings.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct NotificationSettings: GModelType {
    var notifications: [Notification]?
    
    var encoded: [String: Any?] {
        return ["notifications": notifications?.map { $0.encoded }]
    }
    
    init (dict: [String: Any?]) {
        notifications = (dict["notifications"] as? [[String: Any]])?.map { Notification(dict: $0) }
    }
}
