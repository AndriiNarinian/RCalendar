//
//  Properties.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Properties {
    @discardableResult static func insert(from dict: [String: Any]) -> Properties {
        let properties = Dealer<Properties>.inserted
        properties.privat = NSMutableDictionary(dictionary: dict["private"] as! [String: String])
        properties.shared = NSMutableDictionary(dictionary: dict["shared"] as! [String: String])
        
        return properties
    }
}
