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
    let verticalMovementLimit: CGFloat = 70
    
    var hasStarted = false
    var shouldDismissOnScrollViewStop = false
    
    var blackButton: UIButton!
    
    func configure(for vc: UIViewController) {
        viewController = vc
        previousTranslation = nil
        panner.addTarget(self, action: #selector(handlePan(sender:)))
        vc.view.addGestureRecognizer(panner)
        
//        blackButton = UIButton(frame: .zero)
//        blackButton.setTitle("✕", for: .normal)
//        blackButton.setTitleColor(.black, for: .normal)
//        //viewController?.view.superview?.insertSubview(blackButton, belowSubview: viewController?.view ?? UIView())
//        viewController?.presentingViewController?.view.addSubview(blackButton)
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        guard let viewController = viewController else { return }
        let translation = sender.translation(in: viewController.view)
        guard translation.y > 0 else {
            resetView()
            return }
        processInteractiveTransition(sender: sender, movement: translation)
        previousTranslation = translation
    }
    
    func handleTranslation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            viewController?.view.layer.frame.origin.y = -(scrollView.contentOffset.y)
            if viewController?.view.layer.frame.origin.y ?? 0 > verticalMovementLimit {
                viewController?.view.layer.frame.origin.y = verticalMovementLimit
            }
        } else {
            viewController?.view.layer.frame.origin.y = 0
        }
    }
    
    func checkIfNeedToDismiss(_ scrollView: UIScrollView) {
        if viewController?.view.layer.frame.origin.y == verticalMovementLimit && scrollView.contentOffset.y < -verticalMovementLimit {
            shouldDismissOnScrollViewStop = true
        }
    }
    
    func finalizeTranslation(_ scrollView: UIScrollView) {
        if shouldDismissOnScrollViewStop {
            shouldDismissOnScrollViewStop = false
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func resetView() {
        (self.viewController as? DroppingModalVC)?.dataSource?._scrollView?.isUserInteractionEnabled = true
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
                
                viewController.view.layer.frame.origin.y += diff
//                if let DroppingModalVC = viewController as? DroppingModalVC {
//                    let percentage = movement.y / verticalMovementLimit
//                    DroppingModalVC.closeButton.frame.origin.y -= diff
////
////                    DroppingModalVC.blackCloseButtonView.frame.origin.y -= diff
////
//                    blackButton.frame = DroppingModalVC.closeButton.frame
//                    blackButton.titleLabel?.font = DroppingModalVC.closeButton.titleLabel?.font
//                    
//                    
//                }
            } else {
                viewController.view.layer.frame.origin.y = verticalMovementLimit
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
