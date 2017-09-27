//
//  ViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class ViewController: VC, CoreDataTableCompatibleVC, GoogleAPICompatible {
    
    var gIDSignInProxy = GIDSignInProxyObject()
    var coreDataProxy = CoreDataProxyObject()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        gIDSignInProxy.configure(with: self)
        coreDataProxy.configure(with: tableView)
        
        GCalendarExtended.findAll(for: self) { [unowned self] calendarList in
            if let extendedCalendars = calendarList.items {
                extendedCalendars.forEach { calendar in
                    self.save(calendar)
                }
            }
        }
    }
}
