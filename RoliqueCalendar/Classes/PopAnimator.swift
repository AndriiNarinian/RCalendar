//
//  PopAnimator.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/12/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.25
    var presenting = true
    var originFrame = CGRect.zero
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to) ?? UIView()
        let animatedView = presenting ? toView :
            transitionContext.view(forKey: .from)!
        var dismissFillColor = UIColor.clear
        if let eventDetailVC = animatedView.parentViewController as? EventDetailVC {
            dismissFillColor = eventDetailVC.headerColor
        }
        let initialFrame = presenting ? originFrame : animatedView.frame
        let finalFrame = presenting ? animatedView.frame : originFrame
        
        let xScaleFactor = presenting ?
            
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
        
        if presenting {
            animatedView.transform = scaleTransform
            animatedView.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            animatedView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: animatedView)
        
        var transitionColorView: UIView?
        
        if !self.presenting {
            let view = UIView(frame: animatedView.frame)
            view.center = animatedView.center
            view.backgroundColor = dismissFillColor
            view.alpha = 0
            animatedView.addSubview(view)
            transitionColorView = view
        }
        
        UIView.animate(
            withDuration: duration,
            delay:0.0,
            options: UIViewAnimationOptions.curveEaseInOut,
            animations: { [unowned self] in
                animatedView.transform = self.presenting ?
                    CGAffineTransform.identity : scaleTransform
                animatedView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                
                if !self.presenting {
                    transitionColorView?.alpha = 1
                }
            },
            completion: { _ in
                if !self.presenting {
                    self.dismissCompletion?()
                }
                transitionContext.completeTransition(true)
        }
        )
    }
}
