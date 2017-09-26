//
//  Attachment.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

struct Attachment: GModel {
    var fileUrl: String?
    var title: String?
    var mimeType: String?
    var iconLink: String?
    var fileId: String?
    
    var encoded: [String: Any?] {
        return [
            "fileUrl": fileUrl,
            "title": title,
            "mimeType": mimeType,
            "iconLink": iconLink,
            "fileId": fileId
        ]
    }
    
    init (dict: [String: Any?]) {
        fileUrl = dict["fileUrl"] as? String
        title = dict["title"] as? String
        mimeType = dict["mimeType"] as? String
        iconLink = dict["iconLink"] as? String
        fileId = dict["fileId"] as? String
    }
}
