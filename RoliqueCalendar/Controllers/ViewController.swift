//
//  ViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

class ViewController: VC, GoogleAPICompatible {
    
    var gIDSignInProxy = GIDSignInProxyObject()
    var coreDataProxy = CoreDataProxy<CalendarExtended>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        
        gIDSignInProxy.configure(with: self)
        
        let config = CoreDataProxyConfig(
            entityName: String(describing: CalendarExtended.self),
            sortDescriptors: [("summary", true)]
        )
        coreDataProxy.configure(with: tableView, config: config)
        
        Calendar.all(for: self)
    }

}
