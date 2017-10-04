//
//  CalendarList.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

typealias CalendarListCalendarIdsCompletion = ([String]) -> Void

extension CalendarList {
    static func fetch(for vc: GoogleAPICompatible, completion: @escaping CalendarListCalendarIdsCompletion) {
        APIHelper.getExtendedCalendarList(owner: vc) { dict in
            Dealer<CalendarList>.updateWith(array: [DictInsertion(dict)], shouldClearAllBeforeInsert: true, insertion: insert(from:)) {
                let calendars = dict["items"] as? [[String: Any]] ?? [[String: Any]]()
                completion(calendars.map { $0["id"].stringValue })
            }
        }
    }
    
    static func getAllCalendarsForCurrentUser(for owner: GoogleAPICompatible, completion: RCalendarCalendarsCompletion) {
        APIHelper.getExtendedCalendarList(owner: owner) { dict in
            
        }
    }
    
    @discardableResult static func insert(from insertion: Insertion) -> CalendarList {
        let dict = insertion.dictValue
        let calendarList = CalendarList(context: CoreData.backContext)
        calendarList.kind = dict["kind"].string
        calendarList.etag = dict["etag"].string
        calendarList.nextPageToken = dict["nextPageToken"].string
        calendarList.nextSyncToken = dict["nextSyncToken"].string
        
        calendarList.items = dict["items"].maybeInsertDictArray { Calendar.insert(from: $0) }
        
        return calendarList
    }
}
