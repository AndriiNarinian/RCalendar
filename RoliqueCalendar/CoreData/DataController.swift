//
//  DataController.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/27/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import CoreData

class CoreData: NSObject {
    static var controller: DataController {
        return DataController.main
    }
    
    static var container: NSPersistentContainer {
        return controller.persistentContainer
    }
    
    static var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    static var backContext: NSManagedObjectContext {
        return controller.backgroundContext
    }
}

class Dealer<R: NSFetchRequestResult> {
    static func updateWith(array: [Insertion], shouldClearAllBeforeInsert: Bool = false, insertion: (Insertion) -> R) {
        if shouldClearAllBeforeInsert { clearAllObjects() }
        array.forEach { ins in
            if !shouldClearAllBeforeInsert {
                clearIfNeeded(with: "id", value: ins.dictValue["id"] as? String)
            }
            _ = insertion(ins)
        }
        CoreData.context.shouldDeleteInaccessibleFaults = true
        CoreData.controller.saveContext()
    }
    
    static func clearIfNeeded(with key: String, value: String?) {
        if let value = value {
            if exististsObject(with: key, value: value) {
                clearObject(with: key, value: value)
            }
        } else {
            print("no value for key: \(key) for \(String(describing: R.self))")
        }
    }
    
    static func clearAllObjects() {
        let context = CoreData.context
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        do {
            let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
            _ = objects.map { $0.map { context.delete($0) } }
            CoreData.controller.saveContext()
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
    
    static func clearObject(with key: String, value: String?) {
        let context = CoreData.context
        guard let value = value else { return }
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = NSPredicate(format: "\(key) == %@", value)
        do {
            let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
            _ = objects.map { $0.map { context.delete($0) } }
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
    
    static func fetch(with key: String, value: String?) -> R? {
        guard let value = value else { return nil }
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = NSPredicate(format: "\(key) == %@", value)
        do {
            return try CoreData.context.fetch(fetchRequest).first
        } catch { print(error); return nil }
    }
    
    static func exististsObject(with key: String, value: String?) -> Bool {
        guard let value = value else { return false }
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = NSPredicate(format: "\(key) == %@", value)
        do {
            let count = try CoreData.context.count(for: fetchRequest)
            return count > 0
        } catch { print(error); return false }
    }
}

class DataController: NSObject {
    static let main = DataController()
    private override init() {}
    
    func printLibraryPath() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.path)
        }
    }

    // MARK: - Core Data stack
    fileprivate var _backgroundContext: NSManagedObjectContext?
    var backgroundContext: NSManagedObjectContext {
        if let backgroundContext = self._backgroundContext {
            return backgroundContext
        } else {
            let new = self.persistentContainer.newBackgroundContext()
            new.parent = CoreData.context
            self._backgroundContext = new
            return _backgroundContext!
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RCDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveBackgroundContext () {
        let context = backgroundContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

enum InsertionType {
    case dict, string, day
}

protocol Insertion {
    var type: InsertionType { get set }
    var container: Any { get set }
    var dict: [String: Any]? { get }
    var dictValue: [String: Any] { get }
    var string: String? { get }
    var stringValue: String { get }
    var day: (NSDate, NSMutableOrderedSet)? { get }
    var dayValue: (NSDate, NSMutableOrderedSet) { get }
}

extension Insertion {
    var dict: [String: Any]? {
        return container as? [String: Any]
    }
    var string: String? {
        return container as? String
    }
    var dictValue: [String: Any] {
        return container as? [String: Any] ?? [String: Any]()
    }
    var stringValue: String {
        return container as? String ?? ""
    }
    var day: (NSDate, NSMutableOrderedSet)? {
        return container as? (NSDate, NSMutableOrderedSet)
    }
    var dayValue: (NSDate, NSMutableOrderedSet) {
        return container as? (NSDate, NSMutableOrderedSet) ?? (NSDate(), NSMutableOrderedSet())
    }
}

struct DictInsertion: Insertion {
    var type: InsertionType
    var container: Any
    init(_ dict: [String: Any]) {
        self.container = dict
        self.type = .dict
    }
}

struct StringInsertion: Insertion {
    var type: InsertionType
    var container: Any
    init(_ string: String) {
        self.container = string
        self.type = .string
    }
}

struct DayInsertion: Insertion {
    var type: InsertionType
    var container: Any
    init(_ day: (NSDate, NSMutableOrderedSet)) {
        self.container = day
        self.type = .day
    }
}

extension Optional {
    func maybeInsertDictArray<R: NSFetchRequestResult>(_ insertion: @escaping (Insertion) -> R) -> NSMutableOrderedSet? {
        if let array = jsonArray {
            return NSMutableOrderedSet(array: array.map {
                return insertion(DictInsertion($0))
            })
        } else { return nil }
    }
    
    func maybeInsertDictObject<R: NSFetchRequestResult>(_ insertion: (Insertion) -> R) -> R? {
        if let json = json {
            return insertion(DictInsertion(json))
        } else { return nil }
    }
    
    func maybeInsertStringArray<R: NSFetchRequestResult>(_ insertion: (Insertion) -> R) -> NSMutableOrderedSet? {
        if let array = stringArray {
            return NSMutableOrderedSet(array: array.map {
                return insertion(StringInsertion($0))
            })
        } else { return nil }
    }
    
    func maybeInsertStringObject<R: NSFetchRequestResult>(_ insertion: (Insertion) -> R) -> R? {
        if let string = string {
            return insertion(StringInsertion(string))
        } else { return nil }
    }
}
