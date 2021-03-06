//
//  GReminder.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct GReminder: GModelType {
    var method: String?
    var minutes: Int?
    
    var encoded: [String: Any?] {
        return ["method": method, "minutes": minutes]
    }
    
    init?(dict: [String: Any?]?) {
        guard let dict = dict else { return nil }
        method = dict["method"] as? String
        minutes = dict["minutes"] as? Int
    }
}
