//
//  TableEventAttributeView.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/10/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class TableEventAttributeView: NibLoadingView, EventAttributeView, UITableViewDataSource, UITableViewDelegate {
    enum SectionType: Int {
        case accepted = 0, awaiting, declined
        var title: String {
            switch self {
            case .accepted: return "Accepted"
            case .awaiting: return "Awaiting"
            case .declined: return "Declined"
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
        let bundle = Bundle(identifier: "io.rolique.RoCalendar")
        tableView.register(UINib(nibName: "EventCell", bundle: bundle), forCellReuseIdentifier: "EventCell")
    }
    
    var event: Event?
    
    var acceptedUsers: [User]? {
        let accepted = event?.sortedGuests.filter { $0.responseStatus == "accepted" } ?? [User]()
        return accepted.isEmpty ? nil : accepted
    }
    var pendingUsers: [User]? {
        let awaiting = event?.sortedGuests.filter { $0.responseStatus != "accepted" } ?? [User]()
        return awaiting.isEmpty ? nil : awaiting
    }
    var refusedUsers: [User]? {
        let awaiting = event?.sortedGuests.filter { $0.responseStatus == "declined" } ?? [User]()
        return awaiting.isEmpty ? nil : awaiting
    }
    
    var tableData: [SectionType: [User]] {
        var data = [SectionType: [User]]()
        if let acceptedUsers = acceptedUsers { data[.accepted] = acceptedUsers }
        if let pendingUsers = pendingUsers { data[.awaiting] = pendingUsers }
        if let refusedUsers = refusedUsers { data[.declined] = refusedUsers }
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
    
    func getArray(for section: Int) -> [User] {
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: "EventAttributeTableviewCell")
        guard let user = getArray(for: indexPath.section)[safe: indexPath.row] else { return UITableViewCell() }
        
        cell.imageView?.loadImageUsingCacheWithURLString(user.imageUrl.stringValue, placeHolder: nil)
        cell.textLabel?.text = user.displayName ?? user.email
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
