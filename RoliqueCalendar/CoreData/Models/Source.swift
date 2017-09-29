//
//  Source.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Source {
    @discardableResult static func insert(from dict: [String: Any]) -> Source {
        let source = Source(context: CoreData.context)
        source.url = dict["url"].string
        source.title = dict["title"].string
        return source
    }
}
