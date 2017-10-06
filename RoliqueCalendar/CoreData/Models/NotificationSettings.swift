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
        let notificationSettings = Dealer<NotificationSettings>.inserted
        
        notificationSettings.notifications = dict["notifications"].maybeInsertDictArray { Notification.insert(from: $0.dictValue) }
        
        return notificationSettings
    }
    
    @discardableResult static func insertBack(from dict: [String: Any]) -> NotificationSettings {
        let notificationSettings = Dealer<NotificationSettings>.inserted
        
        notificationSettings.notifications = dict["notifications"].maybeInsertDictArray { Notification.insert(from: $0.dictValue) }
        
        return notificationSettings
    }
}
