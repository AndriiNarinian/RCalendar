//
//  User.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension User {
    @discardableResult static func insert(from dict: [String: Any]) -> User {
        let user = User(context: CoreData.context)
        user.id = dict["id"].string
        user.email = dict["email"].string
        user.displayName = dict["displayName"].string
        user.isOrganizer = dict["organizer"].boolValue
        user.isSelf = dict["self"].boolValue
        user.isResource = dict["resource"].boolValue
        user.isOptional = dict["optional"].boolValue
        user.responseStatus = dict["responseStatus"].string
        user.comment = dict["comment"].string
        user.additionalGuests = dict["additionalGuests"].int64Value
        
        return user
    }
}
