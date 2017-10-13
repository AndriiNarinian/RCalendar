//
//  swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/13/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class Interactor: UIPercentDrivenInteractiveTransition {
    let panner = UIPanGestureRecognizer()
    
    fileprivate var shouldFinish = false
    fileprivate weak var viewController: UIViewController?
    fileprivate var previousTranslation: CGPoint?
    fileprivate let percentThreshold: CGFloat = 0.5
    fileprivate let verticalMovementLimit: CGFloat = 70
    
    var hasStarted = false
    
    func configure(for vc: UIViewController) {
        viewController = vc
        previousTranslation = nil
        panner.addTarget(self, action: #selector(handlePan(sender:)))
        vc.view.addGestureRecognizer(panner)
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        guard let viewController = viewController else { return }
        let translation = sender.translation(in: viewController.view)
        guard translation.y >= 0 else {
            resetView()
            
            return }
        processInteractiveTransition(sender: sender, movement: translation)
        previousTranslation = translation
    }
    
    func handleTranslation(_ translation: CGPoint) {
        print(translation)
    }
    
    func resetView() {
        hasStarted = false
        cancel()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
            self.viewController?.view.frame.origin.y = 0
        }, completion: { result in
            
        })
    }
    
    func getProgress(for movement: CGPoint) -> CGFloat {
        let verticalMovement = ((movement.y) / (viewController?.view.bounds.height ?? 0))/4
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        return movement.y >= verticalMovementLimit ? progress : 0
    }
    
    func processInteractiveTransition(sender: UIPanGestureRecognizer, movement: CGPoint) {
        guard let viewController = viewController else { return }
        
        let progress = getProgress(for: movement)
        shouldFinish = progress > percentThreshold
        
        switch sender.state {
        case .began:
            if movement.y >= verticalMovementLimit {
                hasStarted = true
                viewController.dismiss(animated: true, completion: nil)
            }
        case .changed:
            if movement.y < verticalMovementLimit {
                guard let previousTranslation = previousTranslation else { return }
                let diff = movement.y - previousTranslation.y
                
                viewController.view.frame.origin.y += diff
            } else {
                viewController.view.frame.origin.y = verticalMovementLimit
//                if !hasStarted {
//                    hasStarted = true
//                    viewController.dismiss(animated: true, completion: nil)
//                } else {
//                    update(progress)
//                }
            }
        case .cancelled:
            resetView()
        case .ended:
//            hasStarted = false
            movement.y >= verticalMovementLimit
                ? viewController.dismiss(animated: true, completion: nil)
                : resetView()
        default:
            break
        }
    }
}
