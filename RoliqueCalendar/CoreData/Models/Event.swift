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
            Dealer<Event>.updateWith(array: dicts, insertion: insert(from:))
        }
    }
    
    @discardableResult static func insert(from dict: [String: Any]) -> Event {
        let event = Event(context: CoreData.context)
        event.kind = dict["kind"] as? String
        event.etag = dict["etag"].string
        event.id = dict["id"].string
        event.summary = dict["summary"].string
        event.descr = dict["description"].string
        event.location = dict["location"].string
        event.createdAt = dict["created"].maybeInsertStringObject { DateNoTz.insert(from: $0.stringValue) }
//        event.timeZone = dict["timeZone"].string
        event.colorId = dict["colorId"].string
//        event.backgroundColor = dict["backgroundColor"].string
//        event.foregroundColor = dict["foregroundColor"].string
//        event.isSelected = dict["selected"].boolValue
//        event.accessRole = dict["accessRole"].string
        event.attendees = dict["attendees"].maybeInsertDictArray { User.insert(from: $0.dictValue) }
//        event.notificationSettings = dict["notificationSettings"].maybeInsertDictObject { NotificationSettings.insert(from: $0.dictValue) }
//        event.isPrimary = dict["primary"].boolValue
//        event.wasDeleted = dict["deleted"].boolValue
        
        return event
    }
}
