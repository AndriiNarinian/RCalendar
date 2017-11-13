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
        let timeStamp = Dealer<TimeStamp>.inserted
        timeStamp.date = Formatters.gcFormatDate.date(from: dict["date"].stringValue) as Date?
        timeStamp.dateTime = Formatters.gcFormatTz.date(from: dict["dateTime"].stringValue) as Date?
        timeStamp.timeZone = dict["timeZone"].maybeInsertStringObject { DateTz.insert(from: $0.stringValue) }
        timeStamp.dateToUse = timeStamp.dateTime ?? timeStamp.date ?? Date()
        return timeStamp
    }
}
