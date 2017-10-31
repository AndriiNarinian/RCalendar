//
//  Event.swift
//  Roliqueevent
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Event {
    static func all(calendarId: String, for vc: GoogleAPICompatible, bound: PaginationBound? = nil, completion: @escaping () -> Void) {
        APIHelper.getEventList(with: calendarId, for: vc, bound: bound) { dict in
            guard let dicts = dict["items"] as? [[String: Any]] else { return }
            let dictsWithCalendar = dicts.map { dict -> [String: Any] in
                var newDict = dict
                newDict["calendarId"] = calendarId
                return newDict
            }
            Dealer<Event>.updateWith(array: dictsWithCalendar.map { DictInsertion($0) }, shouldClearObject: { event -> [String: Any]? in
                guard let event = event else { return nil }
                let calendarIds = event.calendars.map { $0.id }
                return ["calendarIds": calendarIds]
            }, insertion: insert(from:), completion: completion)
        }
    }
    
    @discardableResult static func insert(from insertion: Insertion) -> Event {
        var dict = insertion.dictValue
        if let originalCalendarId = dict["calendarId"] as? String {
            var calendarIds = [originalCalendarId]
            let calendarIdsToAdd = insertion.dictToSave?["calendarIds"] as? [String]
            if calendarIdsToAdd?.count ?? 0 > 0 {
                calendarIds.append(contentsOf: calendarIdsToAdd!)
            }
            dict["calendarIds"] = calendarIds
        }

        let event = Dealer<Event>.inserted
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
        event.reminders = dict["reminders"].maybeInsertDictObject { EventReminders.insertBack(from: $0.dictValue) }
        event.source = dict["source"].maybeInsertDictObject { Source.insert(from: $0.dictValue) }
        event.attachments = dict["attachments"].maybeInsertDictArray { Attachment.insert(from: $0.dictValue) }

        let calendarData: NSMutableDictionary = [:]
        Unwrap<Calendar>.arrayValueFromSet(dict["calendarIds"].maybeInsertStringArray { Calendar.fetch(from: $0) }).forEach { calendarData[$0.id.stringValue] = $0.dataDict }
        event.calendarData = calendarData
        
        event.dayString = Formatters.gcFormatDate.string(from: (event.start?.dateToUse ?? NSDate()) as Date)
        event.monthString = Formatters.monthAndYear.string(from: (event.start?.dateToUse ?? NSDate()) as Date)
        if let timeStamp = event.dayString, let date = event.start?.dateToUse {
            if let day = Dealer<Day>.fetch(with: NSPredicate(format: "timeStamp == %@", timeStamp)), let events = Unwrap<Event>.arrayFromSet(day.events), !events.contains(event) {
                event.day = day
            } else {
                let day = Day.create(with: date)
                event.day = day
            }
        }
        return event
    }
    
    var sortedGuests: [User] { return Unwrap<User>.arrayValueFromSet(attendees).sorted(by: { (user1, user2) -> Bool in
        guard let status1 = user1.responseStatus, let status2 = user2.responseStatus else { return false }
        return status1 < status2
    })}
    
    var calendars: [(id: String, name: String, colorHex: String)] {
        var retVal = [(id: String, name: String, colorHex: String)]()
        
        if let calendarData = calendarData {
            for (_, value) in calendarData {
                if let dict = value as? [AnyHashable: Any] {
                    retVal.append((id: dict["id"].stringValue, name: dict["name"].stringValue, colorHex: dict["colorHex"].stringValue))
                }
            }
        }
        
        
        return retVal
    }
}
