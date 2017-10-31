//
//  OverlayButton.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/7/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class OverlayButton: NibLoadingView {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        clipsToBounds = false
        backView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height/2
        backView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func configure(color: UIColor? = nil, image: UIImage? = nil, text: String? = nil, target: Any?, selector: Selector) {
        if let color = color { backView.backgroundColor = color }
        
        backView.layer.cornerRadius = frame.size.height/2
        backView.layer.borderColor = UIColor.lightGray.cgColor
        backView.layer.borderWidth = 1.0
        
        imageView.image = image
        textLabel.text = text
        button.addTarget(target, action: selector, for: .touchUpInside)
        
        layer.cornerRadius = frame.size.height/2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowOpacity = 0.5

    }
}
