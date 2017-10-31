//
//  RCalendar.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/3/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

typealias RCalendarCalendarsCompletion = ([Calendar]) -> Void
typealias RCalendarEventsCompletion = ([Event]) -> Void
typealias RCalendarCompletion = () -> Void

class RCalendar {
    static let main = RCalendar()
    fileprivate init() {}
    
    var calendarIds = [String]()
    var bounds: (max: Date, min: Date)?
    var minDate = defaultMinDate
    var maxDate = defaultMaxDate
    
    func startForCurrentUser(withOwner owner: GoogleAPICompatible, completion: @escaping RCalendarCompletion) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        CalendarList.fetch(for: owner) { calendarIds in
            self.calendarIds = calendarIds
            RCalendar.main.getEventsForCalendarsRecurcively(withOwner: owner, for: calendarIds) {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    func loadEventsForCurrentCalendars(withOwner owner: GoogleAPICompatible, bound: PaginationBound? = nil, completion: @escaping RCalendarCompletion) {
        if let bound = bound {
            switch bound {
            case .min:
                //top
                if let preMin = RCalendar.main.bounds?.min {
                    minDate = preMin.addingTimeInterval(-kEventFetchTimeInterval).withoutTime
                    maxDate = preMin
                }
            case .max:
                if let preMax = bounds?.max {
                    minDate = preMax
                    maxDate = preMax.addingTimeInterval(kEventFetchTimeInterval).withoutTime
                }
            }
        }
        getEventsForCalendarsRecurcively(withOwner: owner, for: calendarIds, bound: bound, completion: completion)
    }
    
    fileprivate func getEventsForCalendarsRecurcively(withOwner owner: GoogleAPICompatible, for ids: [String], bound: PaginationBound? = nil, completion: @escaping RCalendarCompletion) {
        var calendars = ids
        if calendars.count > 0 {
            let calendarId = calendars.removeFirst()
            Event.all(calendarId: calendarId, for: owner, bound: bound, completion: { [unowned self] in
                self.getEventsForCalendarsRecurcively(withOwner: owner, for: calendars, bound: bound, completion: completion)
            })
        } else {
            completion()
        }
    }
    
}
