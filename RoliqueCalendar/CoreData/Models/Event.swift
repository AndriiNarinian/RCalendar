//
//  Event.swift
//  Roliqueevent
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Event {
    static func all(calendarId: String, for vc: GoogleAPICompatible) {
        APIHelper.getEventList(with: calendarId, for: vc) { dict in
            guard let dicts = dict["items"] as? [[String: Any]] else { return }
            let dictsWithCalendar = dicts.map { dict -> [String: Any] in
                var newDict = dict
                newDict["calendarId"] = calendarId
                return newDict
            }
            Dealer<Event>.updateWith(array: dictsWithCalendar.map { DictInsertion($0) }, insertion: insert(from:))
//            Dealer<Day>.updateWith(array: makeDays(with: dictsWithCalendar.map { DictInsertion($0) }), insertion: Day.insert(from:))
        }
    }
    
    static func makeDays(with events: [Insertion]) -> Insertion {
        let allDates = events.map { insertion -> Date in
            let start = insertion.dictValue["start"].jsonValue
            let startDate = Formatters.gcFormatDate.date(from: start["date"].stringValue)
            let startDateTime = Formatters.gcFormatTz.date(from: start["dateTime"].stringValue)
            return startDateTime ?? startDate ?? Date()
        }
        let calendar = Foundation.Calendar.current
        
//        let year = calendar.component(.year, from: date)
//        let month = calendar.component(.month, from: date)
//        let day = calendar.component(.day, from: date)
//        
//        Dealer<Event>.fetch(with: <#T##String#>, value: <#T##String?#>)
        return DayInsertion((NSDate(), NSMutableOrderedSet()))
//
    }
    
    @discardableResult static func insert(from insertion: Insertion) -> Event {
        let dict = insertion.dictValue
        let event = Event(context: CoreData.context)
        event.kind = dict["kind"] as? String
        event.etag = dict["etag"].string
        event.id = dict["id"].string
        event.status = dict["status"].string
        event.htmlLink = dict["htmlLink"].string
        event.createdAt = dict["created"].maybeInsertStringObject { DateNoTz.insert(from: $0.stringValue) }
        event.updatedAt = dict["updated"].maybeInsertStringObject { DateNoTz.insert(from: $0.stringValue) }
        event.summary = dict["summary"].string
        event.descr = dict["description"].string
        event.location = dict["location"].string
        event.colorId = dict["colorId"].string
        event.creator = dict["creator"].maybeInsertDictObject { User.insert(from: $0.dictValue) }
        event.organizer = dict["organizer"].maybeInsertDictObject { User.insert(from: $0.dictValue) }
        event.start = dict["start"].maybeInsertDictObject { TimeStamp.insert(from: $0.dictValue) }
        event.end = dict["end"].maybeInsertDictObject { TimeStamp.insert(from: $0.dictValue) }
        event.endTimeUnspecified = dict["endTimeUnspecified"].boolValue
        event.recurrence = NSMutableOrderedSet(array: dict["recurrence"].stringArrayValue)
        event.recurringEventId = dict["recurringEventId"].string
        event.originalStartTime = dict["originalStartTime"].maybeInsertDictObject { TimeStamp.insert(from: $0.dictValue) }
        event.transparency = dict["transparency"].string
        event.visibility = dict["visibility"].string
        event.iCalUID = dict["iCalUID"].string
        event.sequence = dict["sequence"].int64Value
        event.attendees = dict["attendees"].maybeInsertDictArray { User.insert(from: $0.dictValue) }
        event.attendeesOmitted = dict["attendeesOmitted"].boolValue
        event.extendedProperties = dict["extendedProperties"].maybeInsertDictObject { Properties.insert(from: $0.dictValue) }
        event.hangoutLink = dict["hangoutLink"].string
        event.gadget = dict["gadget"].maybeInsertDictObject { Gadget.insert(from: $0.dictValue) }
        event.anyoneCanAddSelf = dict["anyoneCanAddSelf"].boolValue
        event.guestsCanInviteOthers = dict["guestsCanInviteOthers"].boolValue
        event.guestsCanModify = dict["guestsCanModify"].boolValue
        event.guestsCanSeeOtherGuests = dict["guestsCanSeeOtherGuests"].boolValue
        event.privateCopy = dict["privateCopy"].boolValue
        event.locked = dict["locked"].boolValue
        event.reminders = dict["reminders"].maybeInsertDictObject { EventReminders.insert(from: $0.dictValue) }
        event.source = dict["source"].maybeInsertDictObject { Source.insert(from: $0.dictValue) }
        event.attachments = dict["attachments"].maybeInsertDictArray { Attachment.insert(from: $0.dictValue) }
        event.calendar = Dealer<Calendar>.fetch(with: "id", value: dict["calendarId"].string)
        event.dayString = Formatters.gcFormatDate.string(from: (event.start?.dateToUse ?? NSDate()) as Date)
        return event
    }
}
