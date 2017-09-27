//
//  CalendarList.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

typealias ExtendedCalendarCompletion = (CalendarExtended) -> Void
typealias ExtendedCalendarListCompletion = (CalendarExtendedList) -> Void

struct CalendarExtended: GModelType {
    var kind: String?
    var etag: String?
    var id: String?
    var summary: String?
    var description: String?
    var location: String?
    var timeZone: String?
    var colorId: String?
    var backgroundColor: String?
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
            "backgroundColor": backgroundColor,
            "foregroundColor": foregroundColor,
            "selected": isSelected,
            "accessRole": accessRole,
            "defaultReminders": defaultReminders?.map { $0.encoded },
            "notificationSettings": notificationSettings?.encoded,
            "primary": isPrimary,
            "deleted": isDeleted
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
        colorId = dict["colorId"] as? String
        backgroundColor = dict["backgroundColor"] as? String
        foregroundColor = dict["foregroundColor"] as? String
        isSelected = dict["selected"] as? Bool
        accessRole = dict["accessRole"] as? String
        defaultReminders = (dict["defaultReminders"] as? [[String: Any]])?.flatMap { Reminder(dict: $0) }
        notificationSettings = NotificationSettings(dict: (dict["notificationSettings"] as? [String: Any]))
        isPrimary = dict["primary"] as? Bool
        isDeleted = dict["deleted"] as? Bool
    }
}

extension CalendarExtended {
    static func findAll(for owner: BaseVC, completion: @escaping ExtendedCalendarListCompletion) {
        APIHelper.getExtendedCalendarList(owner: owner) { dict in
            guard let extendedCalendarList = CalendarExtendedList(dict: dict) else { return }
            completion(extendedCalendarList)
        }
    }
    
    static func find(withCalendarId calendarId: String, owner: BaseVC, completion: @escaping ExtendedCalendarCompletion) {
        APIHelper.getExtendedCalendar(with: calendarId, for: owner) { dict in
            guard let extendedCalendar = CalendarExtended(dict: dict) else { return }
            completion(extendedCalendar)
        }
    }
}
