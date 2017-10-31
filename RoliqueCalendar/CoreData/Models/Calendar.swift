//
//  Calendar.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/28/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation
import CoreData

extension Calendar {
    static func all(for vc: GoogleAPICompatible) {
        APIHelper.getExtendedCalendars(owner: vc) { dicts in
                Dealer<Calendar>.updateWith(array: dicts.map { DictInsertion($0) }, insertion: insert(from:)){}
        }
    }
    
    @discardableResult static func fetch(from insertion: Insertion) -> Calendar? {
        let id = insertion.stringValue
        let calendar = Dealer<Calendar>.fetch(with: "id", value: id)
        return calendar
    }
    
    @discardableResult static func insert(from insertion: Insertion) -> Calendar {
        let dict = insertion.dictValue
        let calendar = Dealer<Calendar>.inserted
        calendar.kind = dict["kind"] as? String
        calendar.etag = dict["etag"].string
        calendar.id = dict["id"].string
        calendar.summary = dict["summary"].string
        calendar.descr = dict["description"].string
        calendar.location = dict["location"].string
        calendar.timeZone = dict["timeZone"].string
        calendar.colorId = dict["colorId"].string
        calendar.backgroundColor = dict["backgroundColor"].string
        calendar.foregroundColor = dict["foregroundColor"].string
        calendar.isSelected = dict["selected"].boolValue
        calendar.accessRole = dict["accessRole"].string
        calendar.defaultReminders = dict["defaultReminders"].maybeInsertDictArray { Reminder.insert(from: $0.dictValue) }
        calendar.notificationSettings = dict["notificationSettings"].maybeInsertDictObject { NotificationSettings.insert(from: $0.dictValue) }
        calendar.isPrimary = dict["primary"].boolValue
        calendar.wasDeleted = dict["deleted"].boolValue
        
        return calendar
    }
    
    var dataDict: [AnyHashable: Any] {
        return [
            "id": id.stringValue,
            "colorHex": backgroundColor.stringValue,
            "name": summary.stringValue
        ]
    }
}
