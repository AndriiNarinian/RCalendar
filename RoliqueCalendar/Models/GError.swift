//
//  GError.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct GError: GModelType {
    var domain: String?
    var message: String?
    var reason: String?
    
    init?(dict: [String : Any?]?) {
        guard let dict = dict else { return nil }
        domain = dict["domain"] as? String
        message = dict["message"] as? String
        reason = dict["reason"] as? String
    }
    
    var encoded: [String : Any?] {
        return [
            "domain": domain,
            "reason": reason,
            "message": message
        ]
    }
}
