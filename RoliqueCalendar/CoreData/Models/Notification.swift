//
//  Notification.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/28/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Notification {
    @discardableResult static func insert(from dict: [String: Any]) -> Notification {
        let notification = Notification(context: CoreData.context)
        notification.type = dict["type"] as? String
        notification.method = dict["method"] as? String
        return notification
    }
}
