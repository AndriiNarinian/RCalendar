//
//  BaseVC.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/27/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

extension BaseVC {
    func displayError(_ error: String) {
        MultiActionAlert(style: .alert, title: "Error", message: error, buttonTitles: ["Ok"], actions: [{}], owner: self).showAlert()
    }
    
    func displayString(_ string: String) {
        MultiActionAlert(style: .alert, message: string, buttonTitles: ["Ok"], actions: [{}], owner: self).showAlert()
    }
    
    func observeToken(completion: @escaping (String) -> Void) {
        self.observeTokenCompletion = completion
        APIHelper.signIn()
    }
}
