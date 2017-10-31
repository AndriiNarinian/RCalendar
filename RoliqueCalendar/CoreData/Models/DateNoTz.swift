//
//  DateNoTz.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension DateNoTz {
    @discardableResult static func insert(from string: String) -> DateNoTz {
        let dateNoTz = Dealer<DateNoTz>.inserted
        dateNoTz.stringValue = string
        return dateNoTz
    }
    var date: Date? {
        return formatter.date(from: stringValue.stringValue)
    }
    var timeStamp: String? {
        if let date = date { return formatter.string(from: date) } else { return nil }
    }
    var shortString: String? {
        if let date = date { return Formatters.dateAndTime.string(from: date) } else { return nil }
    }
    var formatter: DateFormatter { return Formatters.gcFormat }
}

extension DateTz {
    @discardableResult static func insert(from string: String) -> DateTz {
        let dateNoTz = Dealer<DateTz>.inserted
        dateNoTz.stringValue = string
        return dateNoTz
    }
    var date: Date? {
        return formatter.date(from: stringValue.stringValue)
    }
    var timeStamp: String? {
        if let date = date { return formatter.string(from: date) } else { return nil }
    }
    var shortString: String? {
        if let date = date { return Formatters.dateAndTime.string(from: date) } else { return nil }
    }
    var formatter: DateFormatter { return Formatters.gcFormatTz }
}

