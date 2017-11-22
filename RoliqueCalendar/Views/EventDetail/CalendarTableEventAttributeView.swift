//
//  CalendarTableEventAttributeView.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/10/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class CalendarTableEventAttributeView: NibLoadingView, EventAttributeView, UITableViewDataSource, UITableViewDelegate {
    enum SectionType: Int {
        case own = 0, others
        var title: String {
            switch self {
            case .own: return "Own"
            case .others: return "Others"
            }
        }
    }

    let kHeaderHeight: CGFloat = 28
    let kRowHeight: CGFloat = 38

    var type: EventAttributeViewType?

    @IBInspectable var typeId: Int = 0 {
        didSet {
            self.type = EventAttributeViewType(rawValue: typeId)
        }
    }

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()

        tableView.rowHeight = kRowHeight
        tableView.register(UINib(nibName: "EventCell", bundle: bundle), forCellReuseIdentifier: "EventCell")
    }

    var event: Event?

    var ownCalendars: [(id: String, name: String, colorHex: String)]? {
        return event?.calendars
    }

    var othersCalendars: [(id: String, name: String, colorHex: String)]? {
        return event?.calendars
    }
    
    var tableData: [SectionType: [(id: String, name: String, colorHex: String)]] {
        var data = [SectionType: [(id: String, name: String, colorHex: String)]]()
        if let ownCalendars = ownCalendars { data[.own] = ownCalendars }
        if let othersCalendars = othersCalendars { data[.others] = othersCalendars }
        return data
    }
    
    var tableViewHeight: CGFloat {
        return tableData.keys.map { self.getHeightForTableDataKey($0) }.reduce(0, +)
    }

    var allSections: [SectionType] {
        return Array(tableData.keys).sorted(by: { $0.rawValue < $1.rawValue })
    }

    func getHeightForTableDataKey(_ key: SectionType) -> CGFloat {
        return kHeaderHeight + (kRowHeight * CGFloat(self.tableData[key]?.count ?? 0))
    }

    func getArray(for section: Int) -> [(id: String, name: String, colorHex: String)] {
        guard let key = allSections[safe: section] else { return [] }
        return tableData[key] ?? []
    }

    func update(with event: Event?) {
        self.event = event
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let key = allSections[safe: section] else { return nil }
        return key.title
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TableEventAttributeHeaderView(frame: .zero)
        header.update(with: allSections[safe: section]?.title)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kHeaderHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let key = allSections[safe: section] else { return 0 }

        return tableData[key]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "CalendarTableEventAttributeView")
        guard let calendarData = getArray(for: indexPath.section)[safe: indexPath.row] else { return UITableViewCell() }

//        cell.imageView?.loadImageUsingCacheWithURLString(user.imageUrl.stringValue, placeHolder: nil)
        cell.textLabel?.text = calendarData.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

