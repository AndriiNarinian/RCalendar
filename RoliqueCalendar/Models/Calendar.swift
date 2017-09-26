//
//  Calendar.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

import Foundation

typealias CalendarCompletion = (Calendar) -> Void
typealias CalendarsCompletion = ([Calendar]) -> Void

struct Calendar: GModel {
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
    
    init (dict: [String: Any?]) {
        kind = dict["kind"] as? String
        etag = dict["etag"] as? String
        id = dict["id"] as? String
        summary = dict["summary"] as? String
        description = dict["description"] as? String
        location = dict["location"] as? String
        timeZone = dict["timeZone"] as? String
    }
}

extension Calendar {
    static func find(withCalendarId calendarId: String?, owner: BaseVC, completion: @escaping CalendarCompletion) {
        APIHelper.getCalendar(with: calendarId, for: owner) { dict in
            completion(Calendar(dict: dict))
        }
    }
}
