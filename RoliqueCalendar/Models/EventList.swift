//
//  EventList.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/27/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct EventList: GModelType {
    var kind: String?
    var etag: String?
    var summary: String?
    var description: String?
    var updated: DateNoTz?
    var timeZone: String?
    var accessRole: String?
    var defaultReminders: [Reminder]?
    var nextPageToken: String?
    var nextSyncToken: String?
    var items: [Event]?
    
    init?(dict: [String : Any?]?) {
        guard let dict = dict else { return nil }
        kind = dict["kind"] as? String
        etag = dict["etag"] as? String
        summary = dict["summary"] as? String
        description = dict["description"] as? String
        updated = DateNoTz(dict["updated"] as? String)
        timeZone = dict["timeZone"] as? String
        accessRole = dict["accessRole"] as? String
        defaultReminders = (dict["defaultReminders"] as? [[String: Any]])?.flatMap { Reminder(dict: $0) }
        nextPageToken = dict["nextPageToken"] as? String
        nextSyncToken = dict["nextSyncToken"] as? String
        items = (dict["items"] as? [[String: Any]])?.flatMap { Event(dict: $0) }
    }
    
    var encoded: [String : Any?] {
        return [
            "kind": kind,
            "etag": etag,
            "summary": summary,
            "description": description,
            "updated": updated?.stringValue,
            "timeZone": timeZone,
            "accessRole": accessRole,
            "defaultReminders": defaultReminders?.map { $0.encoded },
            "nextPageToken": nextPageToken,
            "nextSyncToken": nextSyncToken,
            "items": items?.map { $0.encoded }
        ]
    }

}
