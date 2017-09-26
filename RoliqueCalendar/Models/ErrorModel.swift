//
//  ErrorModel.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct ErrorModel: GModel {
    var errors: [GError]?
    var code: Int?
    var message: String?
    
    init(dict: [String : Any?]) {
        errors = (dict["errors"] as? [[String: Any]])?.map { GError(dict: $0) }
        code = dict["code"] as? Int
        message = dict["message"] as? String
    }
    
    var encoded: [String : Any?] {
        return [
            "errors": errors?.map { $0.encoded },
            "code": code,
            "message": message
        ]
    }
}
