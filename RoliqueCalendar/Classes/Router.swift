//
//  Router.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

enum APIMethod: String {
    case get = "GET"
}

enum Router {
    fileprivate static let kBaseGoogleAPIString = "https://www.googleapis.com/calendar/v3/"
    
    case getExtendedCalendarList
    case getExtendedCalendar(id: String)
    case getCalendar(id: String)
    case getEventList(calendarId: String)
    case getEvent(calendarId: String, eventId: String)
    
    var endPoint: String {
        switch self {
        case .getExtendedCalendarList: return "users/me/calendarList"
        case .getExtendedCalendar(let id): return "users/me/calendarList/\(id.encoded)"
        case .getCalendar(let id): return "calendars/\(id.encoded)"
        case .getEventList(let calendarId): return "calendars/\(calendarId.encoded)/events"
        case .getEvent(let calendarId, let eventId): return "calendars/\(calendarId.encoded)/events/\(eventId.encoded)"
        }
    }
    
    var urlString: String {
        return Router.kBaseGoogleAPIString + endPoint
    }
    
    var method: APIMethod {
        switch self {
        case .getExtendedCalendarList: return .get
        case .getExtendedCalendar: return .get
        case .getCalendar: return .get
        case .getEventList: return .get
        case .getEvent: return .get
        }
    }
 
}

fileprivate extension String {
    var encoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
