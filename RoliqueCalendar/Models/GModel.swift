//
//  GModel.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

protocol GModel {
    var encoded: [String: Any?] { get }
    
    init (dict: [String: Any?])
    
    var dictDescription: String { get }
}

extension GModel {
    var dictDescription: String {
        return getDescription(for: encoded)
    }
    
    fileprivate func string(for value: Any?) -> String {
        if let value = value as? StringLiteralType {
            return String(describing: value)
        } else if let dict = value as? [String: Any?] {
            return getDescription(for: dict)
        } else if let dicts = value as? [[String: Any?]] {
            return "[ \(dicts.map{ getDescription(for: $0) }.reduce("", { $0 == "" ? $1 : $0 + ",\n" + $1 })) ]"
        } else {
            return "nil"
        }
    }
    
    fileprivate func getDescription(for dict: [String: Any?]) -> String {
        let strings = dict.map ({ (key, value) -> String in
            return "\(key): \(string(for: value))"
        })
        return "{ \(strings.reduce("", { $0 == "" ? $1 : $0 + "\n" + $1 })) }"
    }
}
