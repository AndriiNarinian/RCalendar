//
//  ViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

class ViewController: VC, CoreDataTableCompatibleVC, GoogleAPICompatible {
    var gIDSignInProxy = GIDSignInProxy()
    var coreDataProxy: CoreDataProxy!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        coreDataProxy = CoreDataProxy(tableView: tableView)
        
        GCalendarExtended.findAll(for: self) { [unowned self] calendarList in
            if let extendedCalendars = calendarList.items {
                extendedCalendars.forEach { calendar in
                    self.save(calendar)
                }
            }
        }
    }
}
