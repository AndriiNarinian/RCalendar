//
//  GModel.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation

protocol GModelType {
    var encoded: [String: Any?] { get }
    init (dict: [String: Any?])
}

struct GModel: GModelType {
    var dict: [String: Any?]
    
    init (dict: [String: Any?]) {
        self.dict = dict
    }
    
    var encoded: [String: Any?] {
        return dict
    }
}

extension GModelType {
    var dictDescription: String {
        return getDescription(for: encoded, shouldShowNil: true, stringTrimmingCount: nil)
    }
    
    var dictNoNilDescription: String {
        return getDescription(for: encoded, shouldShowNil: false, stringTrimmingCount: 10)
    }
    
    fileprivate func string(for value: Any?, shouldShowNil: Bool, stringTrimmingCount: Int?) -> String? {
        if let value = value as? StringLiteralType {
            if let count = stringTrimmingCount {
                return String(describing: value).trimmed(leavingCharactersCount: count)
            } else {
                return String(describing: value)
            }
        } else if let dict = value as? [String: Any?] {
            return getDescription(for: dict, shouldShowNil: shouldShowNil, stringTrimmingCount: stringTrimmingCount)
        } else if let dicts = value as? [[String: Any?]] {
            return "[ \(dicts.map{ getDescription(for: $0, shouldShowNil: shouldShowNil, stringTrimmingCount: stringTrimmingCount) }.reduce("", { $0 == "" ? $1 : $0 + ",\n" + $1 })) ]"
        } else {
            return nil
        }
    }
    
    fileprivate func reduce(array: [String], with separator: String) -> String {
        return array.reduce(with: separator)
    }
    
    fileprivate func getDescription(for dict: [String: Any?], shouldShowNil: Bool, stringTrimmingCount: Int?) -> String {
        let strings = dict.map { (key, value) -> String in
            if let valueString = string(for: value, shouldShowNil: shouldShowNil, stringTrimmingCount: stringTrimmingCount) {
                return "\(key): \(valueString)"
            } else if shouldShowNil {
                return "\(key): nil"
            } else {
                return ""
            }
        }
        return "{ \(strings.reduce(with: ",\n")) }"
    }
}
