//
//  TimeStamp.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension TimeStamp {
    @discardableResult static func insert(from dict: [String: Any]) -> TimeStamp {
        let timeStamp = TimeStamp(context: CoreData.context)
        timeStamp.date = dict["date"].string
        timeStamp.dateTime = dict["dateTime"].string
        timeStamp.timeZone = dict["timeZone"].maybeInsertStringObject { DateTz.insert(from: $0.stringValue) }
        
        return timeStamp
    }
}
