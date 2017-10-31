//
//  TableEventAttributeHeaderView.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/12/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class TableEventAttributeHeaderView: NibLoadingView {
    @IBOutlet weak var label: UILabel!
    
    func update(with text: String?) {
        label.text = text
    }
}
