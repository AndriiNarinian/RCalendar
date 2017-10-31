//
//  Day.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/30/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Day {
    @discardableResult static func insert(from insertion: Insertion) -> Day {
        let dayValue = insertion.dayValue
        let day = Dealer<Day>.inserted
        day.date = dayValue.0
        day.events = dayValue.1
        
        return day
    }
    
    @discardableResult static func create(with date: NSDate) -> Day {
        let day = Dealer<Day>.inserted
        day.date = date
        day.monthString = Formatters.monthAndYear.string(from: date as Date)
        day.timeStamp = Formatters.gcFormatDate.string(from: date as Date)
        return day
    }
    
    var sortedEvents: [Event] { return Unwrap<Event>.arrayValueFromSet(events).sorted(by: { (event1, event2) -> Bool in
        guard let date1 = event1.start?.dateToUse, let date2 = event2.start?.dateToUse else { return false }
        return (date1 as Date) < (date2 as Date)
    })
    }
}
