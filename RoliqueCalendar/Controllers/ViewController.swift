//
//  ViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class ViewController: VC, TableCompatibleVC, GoogleAPICompatible {
    typealias ResultType = CalendarExtended
    
    var gIDSignInProxy = GIDSignInProxyObject()
    var coreDataProxy = ProxyObject<ResultType>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        gIDSignInProxy.configure(with: self)
        
        let config = ProxyConfig(entityName: "CalendarExtended", sortDescriptors: [("summary", true)])
        
        coreDataProxy.configure(with: tableView, config: config)
        
        GCalendarExtended.findAll(for: self) { [unowned self] calendarList in
            if let extendedCalendars = calendarList.items {
                extendedCalendars.forEach { calendar in
                    self.save(with: calendar.id)
                }
            }
        }
    }
}
