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
}

class Dealer<R: NSFetchRequestResult> {
    static func updateWith(array: [[String: Any]], insertion: ([String: Any]) -> R) {
        array.forEach { dict in
            if exististsObject(with: dict["id"] as? String) {
                clearObject(withId: dict["id"] as! String)
            }
            _ = insertion(dict)
        }
        CoreData.controller.saveContext()
    }
    
    static func clearAllObjects() {
        let context = CoreData.context
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        do {
            let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
            CoreData.controller.saveContext()
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
    
    static func clearObject(withId id: String) {
        let context = CoreData.context
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
            _ = objects.map{$0.map{context.delete($0)}}
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
    
    static func exististsObject(with id: String?) -> Bool {
        guard let id = id else { return false }
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            return try CoreData.context.count(for: fetchRequest) > 0
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
}
