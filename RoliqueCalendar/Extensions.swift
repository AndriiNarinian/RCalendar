//
//  Extensions.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

//GRADIENT VIEW
internal class GradientViewConfig: NSObject {
    var color1: UIColor = .clear
    var color2: UIColor = .clear
    var startPoint: CGPoint = .zero
    var endPoint: CGPoint = .zero
    var locations: [NSNumber]?
}

class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
}

extension GradientView {
    private struct AssociatedKeys {
        static var gradientConfig = "gradientConfig"
    }
    
    internal var gradientConfig: GradientViewConfig {
        get {
            if let config = objc_getAssociatedObject(self, &AssociatedKeys.gradientConfig) as? GradientViewConfig {
                return config
            }
            let config = GradientViewConfig()
            self.gradientConfig = config
            return config
        }
        set { objc_setAssociatedObject(self, &AssociatedKeys.gradientConfig, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @IBInspectable public var grColor1: UIColor {
        get { return gradientConfig.color1 }
        set {
            gradientConfig.color1 = newValue
            apply()
        }
    }
    
    @IBInspectable public var grColor2: UIColor {
        get { return gradientConfig.color2 }
        set {
            gradientConfig.color2 = newValue
            apply()
        }
    }
    
    @IBInspectable public var startPoint: CGPoint {
        get { return gradientConfig.startPoint }
        set {
            gradientConfig.startPoint = newValue
            apply()
        }
    }
    
    @IBInspectable public var endPoint: CGPoint {
        get { return gradientConfig.endPoint }
        set {
            gradientConfig.endPoint = newValue
            apply()
        }
    }
    public var locations: [NSNumber]? {
        get { return gradientConfig.locations }
        set {
            gradientConfig.locations = newValue
            apply()
        }
    }
    private func apply() {
        if let layer = layer as? CAGradientLayer {
            layer.colors = [grColor1.cgColor, grColor2.cgColor]
            layer.startPoint = startPoint
            layer.endPoint = endPoint
            layer.locations = locations
        }
    }
}

extension UIImageView {
    func loadImageUsingCacheWithURLString(_ URLString: String, placeHolder: UIImage?) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(error?.localizedDescription ?? "")")
                    DispatchQueue.main.async {
                        self.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}

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
    var stringValue: String {
        switch self {
        case .some(let wrapped):
            if let str = (wrapped as? String) {
                return str
            }
        default: break
        }
        return ""
    }
    
    var string: String? {
        switch self {
        case .some(let wrapped):
            if let str = (wrapped as? String) {
                return str
            }
        default: break
        }
        return nil
    }
    
    var stringArrayValue: [String] {
        switch self {
        case .some(let wrapped):
            if let str = (wrapped as? [String]) {
                return str
            }
        default: break
        }
        return [""]
    }
    
    var stringArray: [String]? {
        switch self {
        case .some(let wrapped):
            if let str = (wrapped as? [String]) {
                return str
            }
        default: break
        }
        return nil
    }
    
    var int64Value: Int64 {
        switch self {
        case .some(let wrapped):
            if let int = (wrapped as? Int) {
                return Int64(int)
            }
        default: break
        }
        return 0
    }
    
    var int64: Int64? {
        switch self {
        case .some(let wrapped):
            if let int = (wrapped as? Int) {
                return Int64(int)
            }
        default: break
        }
        return nil
    }
    
    var boolValue: Bool {
        switch self {
        case .some(let wrapped):
            if let bool = (wrapped as? Bool) {
                return bool
            }
        default: break
        }
        return false
    }
    
    var bool: Bool? {
        switch self {
        case .some(let wrapped):
            if let bool = (wrapped as? Bool) {
                return bool
            }
        default: break
        }
        return nil
    }
    
    var jsonArrayValue: [[String: Any]] {
        switch self {
        case .some(let wrapped):
            if let array = (wrapped as? [[String: Any]]) {
                return array
            }
        default: break
        }
        return [[String: Any]]()
    }
    
    var jsonArray: [[String: Any]]? {
        switch self {
        case .some(let wrapped):
            if let array = (wrapped as? [[String: Any]]) {
                return array
            }
        default: break
        }
        return nil
    }
    
    var jsonValue: [String: Any] {
        switch self {
        case .some(let wrapped):
            if let json = (wrapped as? [String: Any]) {
                return json
            }
        default: break
        }
        return [String: Any]()
    }
    
    var json: [String: Any]? {
        switch self {
        case .some(let wrapped):
            if let json = (wrapped as? [String: Any]) {
                return json
            }
        default: break
        }
        return nil
    }
}

extension Optional {
    func unwrapString<W: ExpressibleByStringLiteral>() -> W {
        switch self {
        case .some(let wrapped):
            return wrapped as! W
        default: return ""
        }
    }
}

extension Optional {
    func unwrapInt<W: ExpressibleByIntegerLiteral>() -> W {
        switch self {
        case .some(let wrapped):
            return wrapped as! W
        default: return 0
        }
    }
}

extension Optional {
    func unwrapFloat<W: ExpressibleByFloatLiteral>() -> W {
        switch self {
        case .some(let wrapped):
            return wrapped as! W
        default: return 0.0
        }
    }
}
