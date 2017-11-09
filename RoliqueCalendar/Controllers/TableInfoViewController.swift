//
//  TableInfoViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 11/9/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

protocol StringColorDescribable {
    var title: String { get }
    var color: UIColor { get }
    
    func getConfiguredCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}

struct StringColorConfig {
    var dataSource: [StringColorDescribable]
    var rowHeight: CGFloat
    var cellTypes: [UITableViewCell.Type]
    
    init(dataSource: [StringColorDescribable], rowHeight: CGFloat, cellTypes: [UITableViewCell.Type]) {
        self.rowHeight = rowHeight
        self.dataSource = dataSource
        self.cellTypes = cellTypes
    }
}

final class TableInfoViewController: UIViewController {
    class func deploy(with calendars: [Calendar], selectedCalendars: [Calendar]? = nil, completion: (([Calendar]) -> Void)? = nil) -> TableInfoViewController {
        let vc = TableInfoViewController.instantiateFromStoryboardId(.main)
        vc.calendars = calendars
        vc.selectedCalendars = selectedCalendars ?? calendars
        vc.handler = completion
        return vc
    }
    fileprivate var handler: (([Calendar]) -> Void)?
    fileprivate var calendars: [Calendar]!
    fileprivate var calendarSelection: [Int: Bool] = [:]
    fileprivate var selectedCalendars: [Calendar] = [] {
        didSet {
            print(selectedCalendars.map { $0.summary })
        }
    }
    
    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {}
    }
    @IBOutlet fileprivate weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handler?(selectedCalendars)
    }
}

// MARK: - UITableViewDelegate
extension TableInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        calendarSelection[indexPath.row] = !(calendarSelection[indexPath.row] ?? false)
        
        let currentFlag = calendarSelection[indexPath.row] ?? false
        calculateSelectedCalendars()
        if indexPath.row == 0 {
            if calendarSelection[0] == true {
                for (calendarIdx, _) in calendars.enumerated() {
                    calendarSelection[calendarIdx + 1] = true
                }
            } else {
                calendarSelection[0] = true
            }
        } else {
            if currentFlag {
                calendarSelection[0] = selectedCalendars == calendars
            } else {
                calendarSelection[0] = false
                if selectedCalendars.count == 0 { calendarSelection[indexPath.row] = true }
            }
        }
        calculateSelectedCalendars()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension TableInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarSelectionCell") as! CalendarSelectionCell
        if indexPath.row == 0 {
            cell.configure(with: "all", color: .black)
        } else {
            let calendar = calendars[indexPath.row - 1]
            cell.configure(with: calendar.summary, color: UIColor(hexString: calendar.backgroundColor!))
        }
        cell.accessoryType = calendarSelection[indexPath.row] == true ? .checkmark : .none
        return cell
    }
}

// MARK: - Private
fileprivate extension TableInfoViewController {
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CalendarSelectionCell", bundle: bundle), forCellReuseIdentifier: "CalendarSelectionCell")
        populateselectionData()
    }
    
    func populateselectionData() {
        calendarSelection[0] = selectedCalendars == calendars
        for (index, value) in calendars.enumerated() {
            calendarSelection[index + 1] = selectedCalendars.contains(value)
        }
        calculateSelectedCalendars()
        tableView.reloadData()
    }
    
    func calculateSelectedCalendars() {
        var cals = [Calendar]()
        for (index, calendar) in calendars.enumerated() {
            if calendarSelection[index + 1] == true { cals.append(calendar) }
        }
        selectedCalendars = cals
    }
}
