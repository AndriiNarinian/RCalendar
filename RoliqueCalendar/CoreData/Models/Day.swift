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
        let day = Day(context: CoreData.backContext)
        day.date = dayValue.0
        day.events = dayValue.1
        
        return day
    }
}
