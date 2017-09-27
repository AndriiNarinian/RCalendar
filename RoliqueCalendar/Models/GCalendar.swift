//
//  GCalendar.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

import Foundation

typealias CalendarCompletion = (GCalendar) -> Void
typealias CalendarsCompletion = ([GCalendar]) -> Void

struct GCalendar: GModelType {
    var kind: String?
    var etag: String?
    var id: String?
    var summary: String?
    var description: String?
    var location: String?
    var timeZone: String?
    
    var encoded: [String: Any?] {
        return [
            "kind": kind,
            "etag": etag,
            "id": id,
            "summary": summary,
            "description": description,
            "location": location,
            "timeZone": timeZone
        ]
    }
    
    init?(dict: [String: Any?]?) {
        guard let dict = dict else { return nil }
        kind = dict["kind"] as? String
        etag = dict["etag"] as? String
        id = dict["id"] as? String
        summary = dict["summary"] as? String
        description = dict["description"] as? String
        location = dict["location"] as? String
        timeZone = dict["timeZone"] as? String
    }
}

extension GCalendar {
    static func find(withCalendarId calendarId: String?, owner: GoogleAPICompatible, completion: @escaping CalendarCompletion) {
        APIHelper.getCalendar(with: calendarId, for: owner) { dict in
            guard let calendar = GCalendar(dict: dict) else { return }
            completion(calendar)
        }
    }
}
