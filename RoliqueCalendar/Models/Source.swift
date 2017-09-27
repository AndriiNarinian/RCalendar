//
//  Source.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct Source: GModelType {
    var url: String?
    var title: String?
    
    var encoded: [String: Any?] {
        return ["url": url, "title": title]
    }
    init?(dict: [String: Any?]?) {
        guard let dict = dict else { return nil }
        url = dict["url"] as? String
        title = dict["title"] as? String
    }
}
