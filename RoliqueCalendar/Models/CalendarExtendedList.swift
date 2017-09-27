//
//  CalendarExtendedList.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/27/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation



struct CalendarExtendedList: GModelType {
    var kind: String?
    var etag: String?
    var nextPageToken: String?
    var nextSyncToken: String?
    var items: [CalendarExtended]?
    
    init?(dict: [String: Any?]?) {
        guard let dict = dict else { return nil }
        kind = dict["kind"] as? String
        etag = dict["etag"] as? String
        nextPageToken = dict["nextPageToken"] as? String
        nextSyncToken = dict["nextSyncToken"] as? String
        items = (dict["items"] as? [[String: Any]])?.flatMap { CalendarExtended(dict: $0) }
    }
    
    var encoded: [String: Any?] {
        return [
            "kind": kind,
            "etag": etag,
            "nextPageToken": nextPageToken,
            "nextSyncToken": nextSyncToken,
            "items": items?.map { $0.encoded }
        ]
    }
}

