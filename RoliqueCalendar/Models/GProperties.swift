//
//  GProperties.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct GProperties: GModelType {
    var `private`: [String: String]?
    var shared: [String: String]?
    
    init?(dict: [String : Any?]?) {
        guard let dict = dict else { return nil }
        `private` = dict["private"] as? [String: String]
        shared = dict["shared"] as? [String: String]
    }
    
    var encoded: [String : Any?] {
        return [
            "private": `private`,
            "shared": shared
        ]
    }
}
