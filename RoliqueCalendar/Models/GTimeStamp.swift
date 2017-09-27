//
//  GTimeStamp.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct GTimeStamp: GModelType {
    var date: Date?
    var dateTime: GDateTz?
    var timeZone: String?
    
    init?(dict: [String : Any?]?) {
        guard let dict = dict else { return nil }
        date = dict["date"] as? Date
        dateTime = GDateTz(dict["dateTime"] as? String)
        timeZone = dict["timeZone"] as? String
    }
    
    var encoded: [String : Any?] {
        return [
            "date": date,
            "dateTime": dateTime?.stringValue,
            "timeZone": timeZone
        ]
    }
}
