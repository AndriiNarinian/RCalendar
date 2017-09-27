//
//  GUser.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct GUser: GModelType {
    var id: String?
    var email: String?
    var displayName: String?
    var isSelf: Bool?
    var isResource: Bool?
    var isOptional: Bool?
    var responseStatus: String?
    var comment: String?
    var additionalGuests: Int?
    
    init?(dict: [String : Any?]?) {
        guard let dict = dict else { return nil }
        id = dict["id"] as? String
        email = dict["email"] as? String
        displayName = dict["displayName"] as? String
        isSelf = dict["self"] as? Bool
        isResource = dict["resource"] as? Bool
        isOptional = dict["optional"] as? Bool
        responseStatus = dict["responseStatus"] as? String
        comment = dict["comment"] as? String
        additionalGuests = dict["additionalGuests"] as? Int
    }
    
    var encoded: [String : Any?] {
        return [
            "id": id,
            "email": email,
            "displayName": displayName,
            "self": isSelf,
            "resource": isResource,
            "optional": isOptional,
            "responseStatus": responseStatus,
            "comment": comment,
            "additionalGuests": additionalGuests
        ]
    }
}
