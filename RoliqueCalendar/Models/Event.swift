//
//  Event.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

typealias EventCompletion = (Event) -> Void
typealias EventsCompletion = ([Event]) -> Void

struct Event: GModelType {
    var kind: String?
    var etag: String?
    var id: String?
    var status: String?
    var htmlLink: String?
    var created: DateNoTz?
    var updated: DateNoTz?
    var summary: String?
    var description: String?
    var location: String?
    var colorId: String?
    var creator: User?
    var organizer: User?
    var start: TimeStamp?
    var end: TimeStamp?
    var endTimeUnspecified: Bool?
    var recurrence: [String]?
    var recurringEventId: String?
    var originalStartTime: TimeStamp?
    var transparency: String?
    var visibility: String?
    var iCalUID: String?
    var sequence: Int?
    var attendees: [User]?
    var attendeesOmitted: Bool?
    var extendedProperties: Properties?
    var hangoutLink: String?
    var gadget: Gadget?
    var anyoneCanAddSelf: Bool?
    var guestsCanInviteOthers: Bool?
    var guestsCanModify: Bool?
    var guestsCanSeeOtherGuests: Bool?
    var privateCopy: Bool?
    var locked: Bool?
    var reminders: EventReminders?
    var source: Source?
    var attachments: [Attachment]?
    
    var encoded: [String: Any?] {
        return [
                "kind": kind,
                "etag": etag,
                "id": id,
                "status": status,
                "htmlLink": htmlLink,
                "created": created?.stringValue,
                "updated": updated?.stringValue,
                "summary": summary,
                "description": description,
                "location": location,
                "colorId": colorId,
                "creator": creator,
                "organizer": organizer,
                "start": start,
                "end": end,
                "endTimeUnspecified": endTimeUnspecified,
                "recurrence": recurrence,
                "recurringEventId": recurringEventId,
                "originalStartTime": originalStartTime,
                "transparency": transparency,
                "visibility": visibility,
                "iCalUID": iCalUID,
                "sequence": sequence,
                "attendees": attendees,
                "attendeesOmitted": attendeesOmitted,
                "extendedProperties": extendedProperties,
                "hangoutLink": hangoutLink,
                "gadget": gadget,
                "anyoneCanAddSelf": anyoneCanAddSelf,
                "guestsCanInviteOthers": guestsCanInviteOthers,
                "guestsCanModify": guestsCanModify,
                "guestsCanSeeOtherGuests": guestsCanSeeOtherGuests,
                "privateCopy": privateCopy,
                "locked": locked,
                "reminders": reminders,
                "source": source,
                "attachments": attachments
        ]
    }
    
    init (dict: [String: Any?]) {
        kind = dict["kind"] as? String
        etag = dict["etag"] as? String
        id = dict["id"] as? String
        status = dict["status"] as? String
        htmlLink = dict["htmlLink"] as? String
        created = DateNoTz(dict["created"] as? String)
        updated = DateNoTz(dict["updated"] as? String)
        summary = dict["summary"] as? String
        description = dict["description"] as? String
        location = dict["location"] as? String
        colorId = dict["colorId"] as? String
        creator = User(dict: (dict["creator"] as? [String: Any]) ?? [String: Any]())
        organizer = User(dict: (dict["organizer"] as? [String: Any]) ?? [String: Any]())
        start = TimeStamp(dict: (dict["start"] as? [String: Any]) ?? [String: Any]())
        end = TimeStamp(dict: (dict["end"] as? [String: Any]) ?? [String: Any]())
        endTimeUnspecified = dict["endTimeUnspecified"] as? Bool
        recurrence = dict["recurrence"] as? [String]
        recurringEventId = dict["recurringEventId"] as? String
        originalStartTime = TimeStamp(dict: (dict["originalStartTime"] as? [String: Any]) ?? [String: Any]())
        transparency = dict["transparency"] as? String
        visibility = dict["visibility"] as? String
        iCalUID = dict["iCalUID"] as? String
        sequence = dict["sequence"] as? Int
        attendees = (dict["attendees"] as? [[String: Any]])?.map { User(dict: $0) }
        attendeesOmitted = dict["attendeesOmitted"] as? Bool
        extendedProperties = Properties(dict: (dict["extendedProperties"] as? [String: Any]) ?? [String: Any]())
        hangoutLink = dict["hangoutLink"] as? String
        gadget = Gadget(dict: (dict["gadget"] as? [String: Any]) ?? [String: Any]())
        anyoneCanAddSelf = dict["anyoneCanAddSelf"] as? Bool
        guestsCanInviteOthers = dict["guestsCanInviteOthers"] as? Bool
        guestsCanModify = dict["guestsCanModify"] as? Bool
        guestsCanSeeOtherGuests = dict["guestsCanSeeOtherGuests"] as? Bool
        privateCopy = dict["privateCopy"] as? Bool
        locked = dict["locked"] as? Bool
        reminders = EventReminders(dict: (dict["reminders"] as? [String: Any]) ?? [String: Any]())
        source = Source(dict: (dict["source"] as? [String: Any]) ?? [String: Any]())
        attachments = (dict["attachments"] as? [[String: Any]])?.map { Attachment(dict: $0) }
    }
}

extension Event {
    static func findAll(withCalendarId calendarId: String?, owner: BaseVC, completion: @escaping EventsCompletion) {
        APIHelper.getEvents(with: calendarId, for: owner) { events in
            completion(events.map { Event(dict: $0) })
        }
    }
    
    static func find(withCalendarId calendarId: String?, eventId: String?, owner: BaseVC, completion: @escaping EventCompletion) {
        APIHelper.getEvent(with: calendarId, eventId: eventId, for: owner) { event in
            completion(Event(dict: event))
        }
    }
}
