//
//  GDate.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/27/17.
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
    var shortString: String? {
        if let date = date { return Formatters.dateAndTime.string(from: date) } else { return nil }
    }
}

struct DateTz: GDate {
    var stringValue: String
    init?(_ stringValue: String?) {
        guard let stringValue = stringValue else { return nil }
        self.stringValue = stringValue
    }
    var formatter: DateFormatter { return Formatters.gcFormatTz }
}

struct DateNoTz: GDate {
    var stringValue: String
    init?(_ stringValue: String?) {
        guard let stringValue = stringValue else { return nil }
        self.stringValue = stringValue
    }
    var formatter: DateFormatter { return Formatters.gcFormat }
}
