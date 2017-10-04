//
//  Gadget.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Gadget {
    @discardableResult static func insert(from dict: [String: Any]) -> Gadget {
        let gadget = Gadget(context: CoreData.backContext)
        gadget.type = dict["type"].string
        gadget.title = dict["title"].string
        gadget.link = dict["link"].string
        gadget.iconLink = dict["iconLink"].string
        gadget.width = dict["width"].int64Value
        gadget.height = dict["height"].int64Value
        gadget.display = dict["display"].string
        
        gadget.preferences = NSMutableDictionary(dictionary: dict["preferences"] as! [String: String])
        
        return gadget
    }
}
