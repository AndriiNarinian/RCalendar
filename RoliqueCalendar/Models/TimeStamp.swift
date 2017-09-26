//
//  TimeStamp.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct TimeStamp: GModel {
    var date: Date?
    var email: String?
    var timeZone: String?
    
    init(dict: [String : Any?]) {
        date = dict["date"] as? Date
        email = dict["email"] as? String
        timeZone = dict["timeZone"] as? String
    }
    
    var encoded: [String : Any?] {
        return [
            "date": date,
            "email": email,
            "timeZone": timeZone
        ]
    }
}
