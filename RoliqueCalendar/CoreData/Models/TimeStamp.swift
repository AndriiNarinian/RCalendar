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
        timeStamp.date = Formatters.gcFormatDate.date(from: dict["date"].stringValue) as NSDate?
        timeStamp.dateTime = Formatters.gcFormatTz.date(from: dict["dateTime"].stringValue) as NSDate?
        timeStamp.timeZone = dict["timeZone"].maybeInsertStringObject { DateTz.insert(from: $0.stringValue) }
        timeStamp.dateToUse = timeStamp.dateTime ?? timeStamp.date ?? NSDate()
        return timeStamp
    }
}
