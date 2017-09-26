//
//  ViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class ViewController: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        CalendarExtended.findAll(for: self) { [weak self] calendarLists in
            self?.calendarLists = calendarLists
        }
    }

    @IBOutlet weak var tableView: UITableView!
    var calendarLists = [CalendarExtended]() {
        didSet {
            tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let calendarList = calendarLists[indexPath.row]
        cell.textLabel?.text = calendarList.summary
        cell.detailTextLabel?.text = calendarList.description
        cell.contentView.backgroundColor = UIColor(hexString: calendarList.backGroundColor.string())
        cell.textLabel?.textColor = UIColor(hexString: calendarList.foregroundColor.string())
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let calendarList = calendarLists[indexPath.row]
        print(calendarList.dictDescription)
        Event.findAll(withCalendarId: calendarList.id, owner: self) { [weak self] events in
            events.forEach { self?.displayString($0.dictDescription) }
        }
    }
}
