//
//  CheckInTypeTableViewCell.swift
//  Rolique
//
//  Created by Bohdan Savych on 10/31/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

final class CheckInTypeTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.cornerRadius = 2
        colorView.layer.masksToBounds = true
    }
    
    func configure(with title: String?, color: UIColor?) {
        titleLabel.text = title
        colorView.backgroundColor = color
    }
}
