//
//  ViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

class ViewController: VC, GoogleAPICompatible {
    internal var gIDSignInProxy = GIDSignInProxyObject()
    fileprivate var eventProxy = CoreDataProxy<Day>()
    fileprivate var isLoading = false
    fileprivate var topDay: Day?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 100
        
        tableView.register(UINib(nibName: "DayTableViewCell", bundle: nil), forCellReuseIdentifier: "DayTableViewCell")
        
        gIDSignInProxy.configure(with: self)
        
        let eventProxyConfig = ProxyConfigWithTableView(
            tableView: tableView,
            sortDescriptors: [(#keyPath(Day.date), true)],
            updateMode: .tableViewReload,
            proxyConfigTableViewDelegate: self
        ) { [unowned self] (object, indexPath) -> UITableViewCell in
            if let day = object as? Day {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "DayTableViewCell") as! DayTableViewCell
                cell.update(with: day)
                return cell
            }
            return UITableViewCell()
        }
        eventProxy.configure(config: eventProxyConfig)
        isLoading = true
        scrollToToday(false)
        Spinner.show(on: view)
        RCalendar.main.startForCurrentUser(withOwner: self) { [unowned self] in
            self.isLoading = false
            self.scrollToToday(false)
            Spinner.hide()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    fileprivate func scrollToToday(_ animated: Bool) {
        let sectionInfo = eventProxy.fetchedResultsController?.sections?.filter { $0.name == Formatters.monthAndYear.string(from: Date()) }.first
        guard let day = sectionInfo?.objects?.filter({ object -> Bool in
            guard let date: Date = (object as? Day)?.date as Date? else { return false }
            let upperBound = date.addingTimeInterval(3600 * 24 * 3).withoutTime
            let lowerBound = date.addingTimeInterval(-3600 * 24 * 3).withoutTime
            let isValidInBoinds = (Date().withoutTime < upperBound) && (Date().withoutTime > lowerBound )
            return (date.withoutTime == Date().withoutTime) || isValidInBoinds
        }).first as? Day, let indexPath = eventProxy.fetchedResultsController?.indexPath(forObject: day) else { return }
        tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }
}

fileprivate extension ViewController {
    func loadEvents(bound: PaginationBound? = nil, completion: RCalendarCompletion? = nil) {
        if !isLoading {
            Spinner.show(on: view)
            isLoading = true
            RCalendar.main.loadEventsForCurrentCalendars(withOwner: self, bound: bound) { [unowned self] in
                self.isLoading = false
                Spinner.hide()
                completion?()
            }
        }
    }
}

extension ViewController: ProxyConfigWithTableViewDelegate {
    func didUpdate() {
        if let day = self.topDay, let indexPath = self.eventProxy.fetchedResultsController?.indexPath(forObject: day) {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func willDisplayFirstRow() {
        if !isLoading {
            self.topDay = eventProxy.fetchedResultsController?.object(at: IndexPath(row: 0, section: 0))
        }
        loadEvents(bound: .min) {
            if let day = self.topDay, let indexPath = self.eventProxy.fetchedResultsController?.indexPath(forObject: day) {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                self.topDay = nil
            }
        }
    }
    
    func willDisplayLastRow() {
        loadEvents(bound: .max)
    }
}
