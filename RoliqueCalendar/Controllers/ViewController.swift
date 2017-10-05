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

    var gIDSignInProxy = GIDSignInProxyObject()
    var eventProxy = CoreDataProxy<Day>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 100
        
        tableView.register(UINib(nibName: "DayTableViewCell", bundle: nil), forCellReuseIdentifier: "DayTableViewCell")
        
        gIDSignInProxy.configure(with: self)

        let eventProxyConfig = ProxyConfigWithTableView(tableView: tableView, sortDescriptors: [(#keyPath(Day.date), false)], updateMode: .tableViewReload) { [unowned self] (object, indexPath) -> UITableViewCell in
            if let day = object as? Day {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "DayTableViewCell") as! DayTableViewCell
                cell.update(with: day)
                return cell
            }
            return UITableViewCell()
        }
        eventProxy.configure(config: eventProxyConfig)
        RCalendar.main.startForCurrentUser(withOwner: self) {}
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollToToday()
    }
    
    fileprivate func scrollToToday() {
        let sectionInfo = eventProxy.fetchedResultsController?.sections?.filter { $0.name == Formatters.monthAndYear.string(from: Date()) }.first
        guard let object = sectionInfo?.objects?.filter({ object -> Bool in
            return Formatters.dayNumber.string(from: (object as! Day).date as! Date) == Formatters.dayNumber.string(from: Date())
        }).first as? Day, let indexPath = eventProxy.fetchedResultsController?.indexPath(forObject: object) else { return }
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}
