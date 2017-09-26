//
//  Extensions.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension String {
    
    static var emptyEntity: Any {
        return "" as Any
    }
    
    static var emptyNilEntity: Any {
        let empty: String? = nil
        return empty as Any
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localizedWithFormat(arguments: CVarArg...) -> String {
        return String.localizedStringWithFormat(self.localized, arguments)
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
    }
    
    func trimmed(leavingCharactersCount count: Int) -> String {
        let countToChop = characters.count - count
        return countToChop > 0 ? (self.chopSuffix(countToChop)) + "..." : self
    }
    
    var withoutSpacesAndNewLines: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension Array where Iterator.Element == String {
    func reduce(with separator: String) -> String {
        return self.reduce("", { lh, rh in
            let lhs = String(describing: lh)
            let rhs = String(describing: rh)
            var str: String {
                if lhs == "" {
                    return rhs
                } else if rhs == "" {
                    return lhs
                }  else {
                    return lhs + separator + rhs
                }
            }
            
            return str
        })
    }
}

extension Optional {
    func string<W: ExpressibleByStringLiteral>() -> W {
        switch self {
        case .some(let wrapped):
            return wrapped as! W
        default: return ""
        }
    }
}

extension Optional {
    func int<W: ExpressibleByIntegerLiteral>() -> W {
        switch self {
        case .some(let wrapped):
            return wrapped as! W
        default: return 0
        }
    }
}

extension Optional {
    func float<W: ExpressibleByFloatLiteral>() -> W {
        switch self {
        case .some(let wrapped):
            return wrapped as! W
        default: return 0.0
        }
    }
}
