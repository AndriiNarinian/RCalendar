//
//  Attachment.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/29/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

extension Attachment {
    @discardableResult static func insert(from dict: [String: Any]) -> Attachment {
        let attachment = Dealer<Attachment>.inserted
        attachment.fileId = dict["fileUrl"].string
        attachment.title = dict["title"].string
        attachment.mimeType = dict["mimeType"].string
        attachment.iconLink = dict["iconLink"].string
        attachment.fileId = dict["fileId"].string
        return attachment
    }
}
