//
//  SideShadowLayer.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/7/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

final class SideShadowLayer: CAGradientLayer {
    enum Side: Int {
        case top,
        bottom,
        left,
        right
    }
    
    init(frame: CGRect, side: Side, shadowMagnitude: CGFloat,
         fromColor: UIColor = .black,
         toColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0),
         opacity: Float = 0.5) {
        super.init()
        
        colors = [fromColor.cgColor, toColor.cgColor]
        self.opacity = opacity
        
        switch side {
        case .bottom:
            startPoint = CGPoint(x: 0.5, y: 0.0)
            endPoint = CGPoint(x: 0.5, y: 1.0)
            self.frame = CGRect(x: 0, y: frame.height - shadowMagnitude, width: frame.width, height: shadowMagnitude)
            
        case .top:
            startPoint = CGPoint(x: 0.5, y: 0.0)
            endPoint = CGPoint(x: 0.5, y: 1.0)
            self.frame = CGRect(x: 0, y: 0, width: frame.width, height: shadowMagnitude)
            
        case .left:
            startPoint = CGPoint(x: 0.0, y: 0.5)
            endPoint = CGPoint(x: 1.0, y: 0.5)
            self.frame = CGRect(x: 0, y: 0, width: shadowMagnitude, height: frame.height)
            
        case .right:
            startPoint = CGPoint(x: 1.0, y: 0.5)
            endPoint = CGPoint(x: 0.0, y: 0.5)
            self.frame = CGRect(x: frame.width - shadowMagnitude, y: 0, width: shadowMagnitude, height: frame.height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
}

extension CALayer {
    func animateOpacity(to value: CGFloat, with duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: #keyPath(opacity))
        animation.fromValue = opacity
        animation.toValue = Float(value)
        animation.duration = duration
        add(animation, forKey: #keyPath(opacity))
        opacity = Float(value)
    }
}
