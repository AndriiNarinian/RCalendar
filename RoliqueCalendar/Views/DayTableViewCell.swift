//
//  DayTableViewCell.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/4/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var movingView: UIView!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var dayName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func update(with day: Day) {
        guard let date = day.date as Date? else { return }
        dayNumber.text = Formatters.dayNumber.string(from: date)
        dayName.text = Formatters.dayNameShort.string(from: date)
        
        
        
        
        guard let events = (day.events?.array as? [Event]) else { return }
        let views = events.map { event -> EventView in
            let view = EventView(frame: .zero)
            view.update(with: event)
            return view
        }
        views.forEach { eventView in
            guard stackView.arrangedSubviews.filter({ arrangedView in
                return (arrangedView as? EventView) == eventView
            }).count == 0 else { return }
            
            stackView.addArrangedSubview(eventView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movingView.layer.frame.origin.y = 0
        stackView.arrangedSubviews.forEach { [unowned self] subview in
            self.stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    func parentTableViewDidScroll(_ rect: CGRect) {
        guard rect.origin.y < 0 else {
            movingView.layer.frame.origin.y = 0
            
            return }
        var newY = -rect.origin.y
        if newY > (stackView.frame.height - movingView.frame.height) { newY = (stackView.frame.height - movingView.frame.height) }
        UIView.animate(withDuration: 0) { 
            
        }
        movingView.layer.frame.origin.y = newY
    }
}
