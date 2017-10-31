//
//  Spinner.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/6/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class Spinner {
    static let shared: Spinner = Spinner()
    private init () {}
    
    lazy var activityView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(activityIndicatorStyle: .gray)
    }()
    
    static func show(on view: UIView) {
        shared.activityView.isHidden = false
        shared.activityView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shared.activityView.center = view.center
        view.addSubview(shared.activityView)
        if !shared.activityView.isAnimating { shared.activityView.startAnimating() }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            shared.activityView.stopAnimating()
            shared.activityView.removeFromSuperview()
        }
    }
}
