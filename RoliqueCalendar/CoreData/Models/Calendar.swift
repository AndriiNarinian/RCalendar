//
//  Calendar.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/28/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation
import CoreData

extension Calendar {
    static func all(for vc: GoogleAPICompatible) {
        APIHelper.getExtendedCalendars(owner: vc) { dicts in
            self.updateWith(array: dicts)
        }
    }
    
    static func updateWith(array: [[String: Any]]) {
        array.forEach { dict in
            if exististsCalendarExtended(with: dict["id"] as? String) {
                clearCalendar(withId: dict["id"] as! String)
            }
            insert(from: dict)
        }
        CoreData.controller.saveContext()
    }
    
    static func clearAllCalendars() {
        let context = CoreData.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CalendarExtended.self))
        do {
            let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
            CoreData.controller.saveContext()
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
    
    static func clearCalendar(withId id: String) {
        let context = CoreData.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CalendarExtended.self))
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
 
    static func exististsCalendarExtended(with id: String?) -> Bool {
        guard let id = id else { return false }
        let fetchRequest = NSFetchRequest<CalendarExtended>(entityName: "CalendarExtended")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            return try CoreData.context.count(for: fetchRequest) > 0
        } catch { print(error); return false }
    }
    
    @discardableResult static func insert(from dict: [String: Any]) -> CalendarExtended {
        let calendar = CalendarExtended(context: CoreData.context)
        calendar.kind = dict["kind"] as? String
        calendar.etag = dict["etag"] as? String
        calendar.id = dict["id"] as? String
        calendar.summary = dict["summary"] as? String
        calendar.descr = dict["description"] as? String
        calendar.location = dict["location"] as? String
        calendar.timeZone = dict["timeZone"] as? String
        calendar.colorId = dict["colorId"] as? String
        calendar.backgroundColor = dict["backgroundColor"] as? String
        calendar.foregroundColor = dict["foregroundColor"] as? String
        calendar.isSelected = dict["selected"] as? Bool ?? false
        calendar.accessRole = dict["accessRole"] as? String
        if let dicts = dict["defaultReminders"] as? [[String: Any]] {
            calendar.defaultReminders = NSMutableOrderedSet(array: dicts.map { Reminder.insert(from: $0) })
        }
        if let dict = dict["notificationSettings"] as? [String: Any] {
            calendar.notificationSettings =  NotificationSettings.insert(from: dict)
        }
        calendar.isPrimary = dict["primary"] as? Bool ?? false
        calendar.wasDeleted = dict["deleted"] as? Bool ?? false
        
        return calendar
    }
}
