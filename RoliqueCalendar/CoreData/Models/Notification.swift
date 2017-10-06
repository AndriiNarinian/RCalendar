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
        let notification = Dealer<Notification>.inserted
        notification.type = dict["type"].string
        notification.method = dict["method"].string
        return notification
    }
    
    @discardableResult static func insertBack(from dict: [String: Any]) -> Notification {
        let notification = Dealer<Notification>.inserted
        notification.type = dict["type"].string
        notification.method = dict["method"].string
        return notification
    }
}
