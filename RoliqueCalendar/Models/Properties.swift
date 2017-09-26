//
//  Properties.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct Properties: GModelType {
    var `private`: [String: String]?
    var shared: [String: String]?
    
    init(dict: [String : Any?]) {
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
