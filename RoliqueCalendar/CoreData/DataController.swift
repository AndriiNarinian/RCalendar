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

class DataController: NSObject {
    static let main = DataController()
    private override init() {}
    
    func printLibraryPath() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.path)
        }
    }
    
//    var managedObjectContext: NSManagedObjectContext
//    init(completionClosure: @escaping () -> ()) {
//        //This resource is the same name as your xcdatamodeld contained in your project
//        guard let modelURL = Bundle.main.url(forResource: "RCDataModel", withExtension:"momd") else {
//            fatalError("Error loading model from bundle")
//        }
//        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
//        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("Error initializing mom from: \(modelURL)")
//        }
//        
//        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
//        
//        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = psc
//        
//        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
//        queue.async {
//            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
//                fatalError("Unable to resolve document directory")
//            }
//            let storeURL = docURL.appendingPathComponent("RCDataModel.sqlite")
//            do {
//                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
//                //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
//                DispatchQueue.main.sync(execute: completionClosure)
//            } catch {
//                fatalError("Error migrating store: \(error)")
//            }
//        }
//    }
    
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
