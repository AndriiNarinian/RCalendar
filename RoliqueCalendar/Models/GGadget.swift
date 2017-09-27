//
//  GGadget.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct GGadget: GModelType {
    var type: String?
    var title: String?
    var link: String?
    var iconLink: String?
    var width: Int?
    var height: Int?
    var display: String?
    var preferences: [String: String]?
    
    init?(dict: [String : Any?]?) {
        guard let dict = dict else { return nil }
        type = dict["id"] as? String
        title = dict["title"] as? String
        link = dict["link"] as? String
        iconLink = dict["iconLink"] as? String
        width = dict["width"] as? Int
        height = dict["height"] as? Int
        display = dict["display"] as? String
        preferences = dict["preferences"] as? [String: String]
    }
    
    var encoded: [String : Any?] {
        return [
            "type": type,
            "title": title,
            "link": link,
            "iconLink": iconLink,
            "width": width,
            "height": height,
            "display": display,
            "preferences": preferences
        ]
    }
}
