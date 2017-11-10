//
//  GCalendarExtended.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

typealias ExtendedCalendarCompletion = (GCalendarExtended) -> Void
typealias ExtendedCalendarListCompletion = (GCalendarExtendedList) -> Void

struct GCalendarExtended: GModelType {
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
    var defaultReminders: [GReminder]?
    var notificationSettings: GNotificationSettings?
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
        defaultReminders = (dict["defaultReminders"] as? [[String: Any]])?.flatMap { GReminder(dict: $0) }
        notificationSettings = GNotificationSettings(dict: (dict["notificationSettings"] as? [String: Any]))
        isPrimary = dict["primary"] as? Bool
        isDeleted = dict["deleted"] as? Bool
    }
}

extension GCalendarExtended {
    static func findAll(for owner: GoogleAPICompatible, completion: @escaping ExtendedCalendarListCompletion) {
        APIHelper.getExtendedCalendarList(owner: owner, completion: { dict in
            guard let extendedCalendarList = GCalendarExtendedList(dict: dict) else { return }
            completion(extendedCalendarList)
        })
    }
    
    static func find(withCalendarId calendarId: String, owner: GoogleAPICompatible, completion: @escaping ExtendedCalendarCompletion) {
        APIHelper.getExtendedCalendar(with: calendarId, for: owner, completion: { dict in
            guard let extendedCalendar = GCalendarExtended(dict: dict) else { return }
            completion(extendedCalendar)
        })
    }
}
