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
    
    var lastMinOffset: CGFloat?
    var lastBound: PaginationBound?
    
    @IBOutlet weak var overlayButton: OverlayButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        activityIndicator.startAnimating()
        RCalendar.main.startForCurrentUser(withOwner: self) { [unowned self] in
            self.isLoading = false
            self.scrollToToday(true)
            self.activityIndicator.stopAnimating()
        }
        
        overlayButton.configure(text: "today", target: self, selector: #selector(todayButtonAction))
    }
    
    func todayButtonAction() {
        scrollToToday(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    fileprivate func scrollToToday(_ animated: Bool) {
        guard let day = findDay(with: Date()), let indexPath = eventProxy.fetchedResultsController?.indexPath(forObject: day) else { return }
        tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }
    
    fileprivate func findDay(with date: Date) -> Day? {
        let sectionInfo = eventProxy.fetchedResultsController?.sections?.filter { $0.name == Formatters.monthAndYear.string(from: date) }.first
        let day = sectionInfo?.objects?.filter({ object -> Bool in
            guard let date: Date = (object as? Day)?.date as Date? else { return false }
            let upperBound = date.addingTimeInterval(3600 * 24 * 3).withoutTime
            let lowerBound = date.addingTimeInterval(-3600 * 24 * 3).withoutTime
            let isValidInBoinds = (Date().withoutTime < upperBound) && (Date().withoutTime > lowerBound )
            return (date.withoutTime == Date().withoutTime) || isValidInBoinds
        }).sorted(by: { (day1, day2) -> Bool in
            guard let date1 = ((day1 as? Day)?.date) as Date?, let date2 = ((day2 as? Day)?.date) as Date? else { return false }
            return (date1.timeIntervalSince(Date())) > (date2.timeIntervalSince(Date()))
        }).first as? Day
        return day
    }
}

fileprivate extension ViewController {
    func loadEvents(bound: PaginationBound? = nil, completion: RCalendarCompletion? = nil) {
        if !isLoading {
            activityIndicator.startAnimating()
            isLoading = true
            RCalendar.main.loadEventsForCurrentCalendars(withOwner: self, bound: bound) { [unowned self] in
                self.isLoading = false
                self.activityIndicator.stopAnimating()
                completion?()
            }
        }
    }
}

extension ViewController: ProxyConfigWithTableViewDelegate {

    func willUpdate() {
        if lastBound == .min {
            lastMinOffset = tableView.contentSize.height
        }
    }
    
    func didUpdate() {
        guard let lastMinOffset = lastMinOffset, lastBound == .min else { return }
        let diff = tableView.contentSize.height - lastMinOffset
        tableView.setContentOffset(CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + diff), animated: false)
    }
    
    func willDisplayFirstRow() {
        loadEvents(bound: .min)
        lastBound = .min
    }
    
    func willDisplayLastRow() {
        loadEvents(bound: .max)
        lastBound = .max
    }
}
