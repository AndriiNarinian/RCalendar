//
//  CalendarList.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

typealias ExtendedCalendarCompletion = (CalendarExtended) -> Void
typealias ExtendedCalendarsCompletion = ([CalendarExtended]) -> Void

struct CalendarExtended: GModelType {
    var kind: String?
    var etag: String?
    var id: String?
    var summary: String?
    var description: String?
    var location: String?
    var timeZone: String?
    var colorId: String?
    var backGroundColor: String?
    var foregroundColor: String?
    var isSelected: Bool?
    var accessRole: String?
    var defaultReminders: [Reminder]?
    var notificationSettings: NotificationSettings?
    var isPrimary: Bool?
    var isDeleted: Bool?
    
    var encoded: [String: Any?] {
        return [
            "kind": kind,
            "etag": etag,
            "id": id,
            "summary": summary,
            "description": description,
            "location": location,
            "timeZone": timeZone,
            "colorId": colorId,
            "backgroundColor": backGroundColor,
            "foregroundColor": foregroundColor,
            "selected": isSelected,
            "accessRole": accessRole,
            "defaultReminders": defaultReminders?.map { $0.encoded },
            "notificationSettings": notificationSettings?.encoded,
            "primary": isPrimary,
            "deleted": isDeleted
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
        colorId = dict["colorId"] as? String
        backGroundColor = dict["backgroundColor"] as? String
        foregroundColor = dict["foregroundColor"] as? String
        isSelected = dict["selected"] as? Bool
        accessRole = dict["accessRole"] as? String
        defaultReminders = (dict["defaultReminders"] as? [[String: Any]])?.map { Reminder(dict: $0) }
        notificationSettings = NotificationSettings(dict: (dict["notificationSettings"] as? [String: Any]) ?? [String: Any]())
        isPrimary = dict["primary"] as? Bool
        isDeleted = dict["deleted"] as? Bool
    }
}

extension CalendarExtended {
    static func findAll(for owner: BaseVC, completion: @escaping ExtendedCalendarsCompletion) {
        APIHelper.getExtendedCalendars(owner: owner) { dicts in
            completion(dicts.map { CalendarExtended(dict: $0) })
        }
    }
    
    static func find(withCalendarId calendarId: String, owner: BaseVC, completion: @escaping ExtendedCalendarCompletion) {
        APIHelper.getExtendedCalendar(with: calendarId, for: owner) { dict in
            completion(CalendarExtended(dict: dict))
        }
    }
}
