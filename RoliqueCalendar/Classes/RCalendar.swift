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
    
    func startForCurrentUser(withOwner owner: GoogleAPICompatible, completion: @escaping RCalendarCompletion) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        CalendarList.fetch(for: owner) { calendarIds in
            RCalendar.main.getEventsForCalendarsRecurcively(withOwner: owner, for: calendarIds) {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    fileprivate func getEventsForCalendarsRecurcively(withOwner owner: GoogleAPICompatible, for ids: [String], completion: @escaping RCalendarCompletion) {
        var calendars = ids
        if calendars.count > 0 {
            let calendarId = calendars.removeFirst()
            Event.all(calendarId: calendarId, for: owner, completion: { [unowned self] in
                self.getEventsForCalendarsRecurcively(withOwner: owner, for: calendars, completion: completion)
            })
        } else {
            completion()
        }
    }
    
}
