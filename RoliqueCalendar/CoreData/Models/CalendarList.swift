//
//  CalendarList.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension CalendarList {
    static func fetch(for vc: GoogleAPICompatible) {
        APIHelper.getExtendedCalendarList(owner: vc) { dict in
            Dealer<CalendarList>.updateWith(array: [DictInsertion(dict)], shouldClearAllBeforeInsert: true, insertion: insert(from:))
        }
    }
    
    @discardableResult static func insert(from insertion: Insertion) -> CalendarList {
        let dict = insertion.dictValue
        let calendarList = CalendarList(context: CoreData.context)
        calendarList.kind = dict["kind"].string
        calendarList.etag = dict["etag"].string
        calendarList.nextPageToken = dict["nextPageToken"].string
        calendarList.nextSyncToken = dict["nextSyncToken"].string
        
        calendarList.items = dict["items"].maybeInsertDictArray { Calendar.insert(from: $0) }
        
        return calendarList
    }
}
