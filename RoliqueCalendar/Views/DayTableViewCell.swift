//
//  DayTableViewCell.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/4/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movingView: UIView!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var dayName: UILabel!
    
    var day: Day?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.rowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func update(with day: Day) {
        self.day = day
        guard let date = day.date as Date? else { return }
        dayNumber.text = Formatters.dayNumber.string(from: date)
        dayName.text = Formatters.dayNameShort.string(from: date)
        
        tableView.reloadData()
        
        
//        guard let events = (day.events?.array as? [Event]) else { return }
//        let views = events.map { event -> EventView in
//            let view = EventView(frame: .zero)
//            view.update(with: event)
//            return view
//        }
//        views.forEach { eventView in
//            guard stackView.arrangedSubviews.filter({ arrangedView in
//                return (arrangedView as? EventView) == eventView
//            }).count == 0 else { return }
//            
//            stackView.addArrangedSubview(eventView)
//        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movingView.layer.frame.origin.y = 0
        
    }
    
    func parentTableViewDidScroll(_ rect: CGRect) {
        guard rect.origin.y < 0 else {
            movingView.layer.frame.origin.y = 0
            
            return }
        var newY = -rect.origin.y
        if newY > (tableView.frame.height - movingView.frame.height) { newY = (tableView.frame.height - movingView.frame.height) }
        UIView.animate(withDuration: 0) { 
            
        }
        movingView.layer.frame.origin.y = newY
    }
}

extension DayTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return day?.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let event = (day?.events?.array as? [Event])?.first
        cell.textLabel?.text = event?.summary
        cell.detailTextLabel?.text = Formatters.dateAndTime.string(from: (event?.start?.dateToUse ?? NSDate()) as Date)
        if let calendar = event?.calendar {
            cell.contentView.backgroundColor = UIColor(hexString: calendar.backgroundColor.stringValue)
        } else {
            cell.contentView.backgroundColor = .darkGray
        }
        cell.contentView.layer.cornerRadius = 2.0
        
        return cell
    }
}

extension DayTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
