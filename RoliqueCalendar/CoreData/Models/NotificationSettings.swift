//
//  NotificationSettings.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/28/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension NotificationSettings {
    @discardableResult static func insert(from dict: [String: Any]) -> NotificationSettings {
        let notificationSettings = NotificationSettings(context: CoreData.context)
        if let dicts = dict["notifications"] as? [[String: Any]] {
            notificationSettings.notifications = NSMutableOrderedSet(array: dicts.map { Notification.insert(from: $0) })
        }
        return notificationSettings
    }
}
