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
    
    case getExtendedCalendars
    case getExtendedCalendar(id: String)
    case getCalendar(id: String)
    case getEvents(calendarId: String)
    case getEvent(calendarId: String, eventId: String)
    
    var endPoint: String {
        switch self {
        case .getExtendedCalendars: return "users/me/calendarList"
        case .getExtendedCalendar(let id): return "users/me/calendarList/\(id)"
        case .getCalendar(let id): return "calendars/\(id)"
        case .getEvents(let calendarId): return "calendars/\(calendarId)/events"
        case .getEvent(let calendarId, let eventId): return "calendars/\(calendarId)/events/\(eventId)"
        }
    }
    
    var urlString: String {
        return Router.kBaseGoogleAPIString + endPoint
    }
    
    var method: APIMethod {
        switch self {
        case .getExtendedCalendars: return .get
        case .getExtendedCalendar: return .get
        case .getCalendar: return .get
        case .getEvents: return .get
        case .getEvent: return .get
        }
    }
 
}
