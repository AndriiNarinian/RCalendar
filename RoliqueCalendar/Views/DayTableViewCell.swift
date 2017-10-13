//
//  DayTableViewCell.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/4/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

protocol DayTableViewCellDelegate: class {
    func dayTableViewCelldidSelectEvent(cell: DayTableViewCell, on day: Day?, at indexPath: IndexPath)
}

class DayTableViewCell: UITableViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movingView: UIView!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var dayName: UILabel!
    
    var day: Day?
    weak var delegate: DayTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.rowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
    }
    
    func update(with day: Day, delegate: DayTableViewCellDelegate?) {
        self.day = day
        self.delegate = delegate
        tableView.reloadData()
        movingView.layer.frame.origin.y = 0
        
        guard let date = day.date as Date? else { return }
        dayNumber.text = Formatters.dayNumber.string(from: date)
        dayName.text = Formatters.dayNameShort.string(from: date)
        

    }

    func parentTableViewDidScroll(_ rect: CGRect, with day: Day?) {
        guard rect.origin.y < 0 else {
            movingView.layer.frame.origin.y = 0
            
            return }
        var newY = -rect.origin.y
        if newY > (tableView.frame.height - movingView.frame.height) { newY = (tableView.frame.height - movingView.frame.height) }

        movingView.layer.frame.origin.y = newY
    }
}

extension DayTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return day?.sortedEvents.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        let event = day?.sortedEvents[safe: indexPath.row]
        cell.update(with: event)
        
        return cell
    }
}

extension DayTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.dayTableViewCelldidSelectEvent(cell: self, on: day, at: indexPath)
    }
}
