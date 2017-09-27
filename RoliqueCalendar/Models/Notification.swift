//
//  Notification.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct Notification: GModelType {
    var type: String?
    var method: String?
    
    var encoded: [String: Any?] {
        return ["type": type, "method": method]
    }
    init?(dict: [String: Any?]?) {
        guard let dict = dict else { return nil }
        type = dict["type"] as? String
        method = dict["method"] as? String
    }
}
