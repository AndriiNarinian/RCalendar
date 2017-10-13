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

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension Date {
    var withoutTime: Date {
        let formatter = Formatters.gcFormatDate
        return formatter.date(from: formatter.string(from: self))!
    }
}

extension Collection where Indices.Iterator.Element == Index {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
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

enum StoryboardId: String {
    case main = "Main"
}

protocol StoryboardInitializing {}
extension UIViewController: StoryboardInitializing {}
extension UIViewController {
    static func className() -> String {
        return String(describing: self)
    }
    static func instantiateInitial(_ storyboardId: StoryboardId) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardId.rawValue, bundle: nil) as UIStoryboard?
        assert(storyboard != nil, "Storyboard name is incorrect")
        let vc = storyboard?.instantiateInitialViewController()
        assert(vc != nil, "No initialViewcontroller in storyboard")
        return vc!
    }
}

extension StoryboardInitializing where Self: UIViewController {
    
    static func instantiateFromStoryboardId(_ storyboardId: StoryboardId) -> Self {
        let vcIdentifier = self.className()
        
        let storyboard = UIStoryboard(name: storyboardId.rawValue, bundle: nil) as UIStoryboard?
        assert(storyboard != nil, "Storyboard name is incorrect")
        
        let vc = storyboard?.instantiateViewController(withIdentifier: vcIdentifier)
        assert(vc != nil, "ViewController id name is incorrect")
        
        return vc as! Self
    }
}

protocol CellInitializer {}
extension UITableViewCell: CellInitializer {}

extension UITableViewCell {
    static var cellIdentifier: String {
        return String(describing: self)
    }
}

extension CellInitializer where Self: UITableViewCell {
    static func dequeued(with identifier: String, by tableView: UITableView) -> Self {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("no cell for identifier: \(identifier) on tableView: \(tableView)")
        }
        return cell as! Self
    }
    
    static func dequeued(by tableView: UITableView) -> Self {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
            fatalError("no cell for identifier: \(self.cellIdentifier) on tableView: \(tableView)")
        }
        return cell as! Self
    }
}

extension UIStackView {
    func configureViews(for indices: [Int], isHidden: Bool, animated: Bool = true, completion: @escaping () -> Void) {
        guard !animated else {
            UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
                self.configureViews(for: indices, isHidden: isHidden)
            }) { _ in
                completion()
            }
            return
        }
        configureViews(for: indices, isHidden: isHidden)
        completion()
    }
    
    private func configureViews(for indices: [Int], isHidden: Bool) {
        indices.forEach({
            self.arrangedSubviews[safe: $0]?.isHidden = self.arrangedSubviews[$0].isHidden == isHidden ? self.arrangedSubviews[safe: $0]?.isHidden ?? false : isHidden
        })
        indices.forEach({ self.arrangedSubviews[safe: $0]?.alpha = isHidden ? 0 : 1 })
    }
}
