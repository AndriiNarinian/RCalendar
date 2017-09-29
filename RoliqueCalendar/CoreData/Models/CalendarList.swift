//
//  CalendarList.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension CalendarList {
    static func get(for vc: GoogleAPICompatible) {
        APIHelper.getExtendedCalendarList(owner: vc) { dict in
            Dealer<CalendarList>.updateWith(array: [dict], shouldClearAllBeforeInsert: true, insertion: insert(from:))
        }
    }
    
    @discardableResult static func insert(from dict: [String: Any]) -> CalendarList {
        let calendarList = CalendarList(context: CoreData.context)
        calendarList.kind = dict["kind"].string
        calendarList.etag = dict["etag"].string
        calendarList.nextPageToken = dict["nextPageToken"].string
        calendarList.nextSyncToken = dict["nextSyncToken"].string
        
        calendarList.items = dict["items"].maybeInsertDictArray { Calendar.insert(from: $0.dictValue) }
        
        return calendarList
    }
}
