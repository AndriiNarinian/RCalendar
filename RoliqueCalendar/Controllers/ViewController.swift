//
//  ViewController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

extension ViewController: CoreDataTableViewOwner {
    var _tableView: UITableView { return tableView }
}

class ViewController: BaseVC {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeFetchedResultsController()
        tableView.rowHeight = 80
        
        CalendarExtended.findAll(for: self) { [unowned self] calendarList in
            if let extendedCalendars = calendarList.items {
                extendedCalendars.forEach { calendar in
                    self.save(calendar)
                }
            }
        }
    }
    
    fileprivate func save(_ calendar: CalendarExtended) {
        var calendarMO = existingCalendarExtended(with: calendar.id)
        
        if calendarMO == nil {
            let entity = NSEntityDescription.entity(forEntityName: "CalendarExtended", in: self.managedObjectContext)
        
            calendarMO = CalendarExtendedMO(entity: entity!, insertInto: self.managedObjectContext)
        }
        calendarMO?.id = calendar.id
        calendarMO?.etag = calendar.etag
        calendarMO?.summary = calendar.summary
        calendarMO?.descr = calendar.description
        calendarMO?.backgroundColor = calendar.backgroundColor
        calendarMO?.foregroundColor = calendar.foregroundColor
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
    func existingCalendarExtended(with id: String?) -> CalendarExtendedMO? {
        guard let id = id else { return nil }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarExtended")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.includesSubentities = false
        
        var managedExtendedCalendar: CalendarExtendedMO?
        
        do {
            managedExtendedCalendar = try self.managedObjectContext.fetch(fetchRequest).first as? CalendarExtendedMO
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return managedExtendedCalendar
    }
    
}
