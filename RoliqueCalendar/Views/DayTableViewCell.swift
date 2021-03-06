//
//  DayTableViewCell.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/4/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

protocol DayTableViewCellDelegate: class {
    func dayTableViewCell(cell: DayTableViewCell, didSelect event: Event?, at indexPath: IndexPath)
}

open class DayTableViewCell: UITableViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movingView: UIView!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var dayName: UILabel!
    
    var day: Day?
    var filterCalendarIds: [String]?
    
    var events: [Event] {
        let filtered = filterEvents(events: day?.sortedEvents, with: filterCalendarIds)
        return filtered
    }
    
    weak var delegate: DayTableViewCellDelegate?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.rowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.register(UINib(nibName: "EventCell", bundle: bundle), forCellReuseIdentifier: "EventCell")
    }
    
    func filterEvents(events: [Event]?, with calendarIds: [String]?) -> [Event] {
        if let filterCalendarIds = calendarIds {
            return events?.filter({ storedEvent -> Bool in
                var result = false
                for calendarId in filterCalendarIds {
                    let ids = storedEvent.calendars.map { $0.id }
                    if ids.contains(calendarId) { result = true }
                }
                return result
            }) ?? []
        } else {
            return events ?? []
        }
    }
    
    func update(with day: Day, delegate: DayTableViewCellDelegate?, filterCalendarIds: [String]?) {
        self.day = day
        self.filterCalendarIds = filterCalendarIds
        self.delegate = delegate
        
        tableView.reloadData()
        movingView.layer.frame.origin.y = 0
        
        guard let date = day.date as Date? else { return }
        dayNumber.text = Formatters.dayNumber.string(from: date)
        dayName.text = Formatters.dayNameShort.string(from: date)
    }

    var preOffset: CGFloat?
    
    func parentTableViewDidScroll(_ tableView: UITableView, rect: CGRect, with day: Day?) {
        
        //performScrollingEffect(tableView)
        
        guard rect.origin.y < 0 else {
            movingView.layer.frame.origin.y = 0
            
            return }
        var newY = -rect.origin.y
        if newY > (self.tableView.frame.height - movingView.frame.height) { newY = (self.tableView.frame.height - movingView.frame.height) }

        movingView.layer.frame.origin.y = newY

    }
    
    func performScrollingEffect(_ tableView: UITableView) {
        if let preOffset = preOffset {
            let velocity = max(min(tableView.contentOffset.y - preOffset, kScrollEffectVelocityLimit), -kScrollEffectVelocityLimit)
            if let indexPaths = self.tableView.indexPathsForVisibleRows?.sorted(by: { $0.row < $1.row }) {
                indexPaths.forEach { indexPath in
                    let cell = self.tableView.cellForRow(at: indexPath) as? EventCell
                    let backView = (self.tableView.cellForRow(at: indexPath) as! EventCell).backView!
                    let localRect = self.tableView.convert(backView.frame, from: backView)
                    let rect = self.tableView.convert(localRect, to: tableView.superview)
                    
                    let centerY = UIApplication.shared.keyWindow?.center.y ?? 0
                    let deviation = (abs(centerY - rect.origin.y) / centerY) * kScrollEffectDeviationMultiplier
                    cell?.layer.frame.origin.y = (velocity * deviation) + (CGFloat(indexPath.row) * (cell?.frame.size.height ?? 0))
                }
            }
        }
        preOffset = tableView.contentOffset.y
    }
}

extension DayTableViewCell: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        let event = events[safe: indexPath.row]
        cell.update(with: event)
        
        return cell
    }
}

extension DayTableViewCell: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = events[safe: indexPath.row]
        delegate?.dayTableViewCell(cell: self, didSelect: event, at: indexPath)
    }
}
