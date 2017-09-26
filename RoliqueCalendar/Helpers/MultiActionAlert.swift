//
//  MultiActionAlert.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class MultiActionAlert {
    static func pvc() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
    
    let style: UIAlertControllerStyle
    let title: String?
    let message: String?
    let buttonTitles: [String]
    let actions: [(() -> Void)?]
    var owner: UIViewController?
    let actionStyles: [UIAlertActionStyle]?
    let textfieldConfigurationHandler: ((UITextField) -> Void)?
    
    init (style: UIAlertControllerStyle,
          title: String? = nil,
          message: String? = nil,
          buttonTitles: [String],
          actionStyles: [UIAlertActionStyle]? = nil,
          actions: [(() -> Void)?],
          owner: UIViewController? = nil,
          textfieldConfigurationHandler: ((UITextField) -> Void)? = nil) {
        self.style = style
        self.title = title
        self.message = message
        self.buttonTitles = buttonTitles
        self.actions = actions
        self.owner = owner
        self.actionStyles = actionStyles
        self.textfieldConfigurationHandler = textfieldConfigurationHandler
    }
    
    func showAlert() {
        if owner == nil { owner = MultiActionAlert.pvc() }
        let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: self.style)
        alert.popoverPresentationController?.sourceView = owner!.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 30, height: 30)
        for x in 0..<buttonTitles.count {
            let buttonTitle = self.buttonTitles[x]
            let action =  self.actions[x]
            if let actionStyles = self.actionStyles {
                let style = actionStyles[x]
                alert.addAction(UIAlertAction(title: buttonTitle, style: style, handler: {_ in
                    action?()
                }))
            } else {
                alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {_ in
                    action?()
                }))
            }
        }
        if textfieldConfigurationHandler != nil {
            alert.addTextField(configurationHandler: self.textfieldConfigurationHandler)
        }
        owner!.present(alert, animated: true, completion: nil)
    }
}
