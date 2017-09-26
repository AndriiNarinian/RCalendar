//
//  TimeStamp.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

protocol GDate {
    var formatter: DateFormatter { get }
    var stringValue: String { get set }
    init?(_ stringValue: String?)
}

extension GDate {
    var date: Date? {
        return formatter.date(from: stringValue)
    }
    var timeStamp: String? {
        if let date = date { return formatter.string(from: date) } else { return nil }
    }
}

struct TimeStamp: GModelType {
    var date: Date?
    var dateTime: DateTz?
    var timeZone: String?
    
    init(dict: [String : Any?]) {
        date = dict["date"] as? Date
        dateTime = DateTz(dict["dateTime"] as? String)
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

struct DateTz: GDate {
    var stringValue: String
    init?(_ stringValue: String?) {
        if let stringValue = stringValue {
            self.stringValue = stringValue
        } else { return nil }
    }
    var formatter: DateFormatter { return Formatters.gcFormatTz }
}

struct DateNoTz: GDate {
    var stringValue: String
    init?(_ stringValue: String?) {
        if let stringValue = stringValue {
            self.stringValue = stringValue
        } else { return nil }
    }
    var formatter: DateFormatter { return Formatters.gcFormat }
}
