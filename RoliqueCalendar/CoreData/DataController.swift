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
    
    static var mainContext: NSManagedObjectContext {
        return controller.mainContext
    }
    
    static var backContext: NSManagedObjectContext {
        return controller.backgroundContext
    }
    
    static var masterContext: NSManagedObjectContext {
        return controller.masterContext
    }
    
    static func saveContext(completion: @escaping () -> Void) {
        saveBackgroundContext(completion: completion)
    }
    
    static func saveBackgroundContext(completion: @escaping () -> Void) {
        do {
            try backContext.save()
            saveMainContext(completion: completion)
        } catch {
            print(error)
        }
    }
    
    static func saveMainContext(completion: @escaping () -> Void) {
        mainContext.performAndWait {
            do {
                try mainContext.save()
                saveMasterContext()
            } catch {
                print(error)
            }
//            DispatchQueue.main.async {
                completion()
//            }
        }
    }
    
    static func saveMasterContext() {
        masterContext.perform {
            do {
                try masterContext.save()
            } catch {
                print(error)
            }
        }
    }
}

class Dealer<R: NSManagedObject> {
    typealias ObjectClearConfirmationHandler = (R?) -> [String: Any]?
    
    static func updateWith(array: [Insertion], shouldClearAllBeforeInsert: Bool = false, shouldClearObject: ObjectClearConfirmationHandler? = nil, cancellationHandler: (() -> Bool)? = nil, insertion: @escaping (Insertion) -> R, completion: @escaping () -> Void) {
        CoreData.backContext.perform {
            if shouldClearAllBeforeInsert { clearAllObjects() }
            
            array.forEach { ins in
                let isCancelled = cancellationHandler?() ?? false
                guard !isCancelled else {
                    print("skipping events insertion due to cancellation")
                    completion()
                    
                    return
                }
                var insert = ins
                if !shouldClearAllBeforeInsert {
                    insert.dictToSave = self.clearIfNeeded(with: "id", value: ins.dictValue["id"] as? String, shouldClearObject: shouldClearObject)
                }
                _ = insertion(insert)
            }
            let isCancelled = cancellationHandler?() ?? false
            guard !isCancelled else {
                print("skipping events storring due to cancellation")
                completion()

                return
            }
            saveBackgroundContext(completion: completion)
        }
    }
    
    static func saveContext(completion: @escaping () -> Void) {
        saveBackgroundContext(completion: completion)
    }
    
    static func saveBackgroundContext(completion: @escaping () -> Void) {
        do {
            try CoreData.backContext.save()
            saveMainContext(completion: completion)
        } catch {
            print(error)
        }
    }
    
    static func saveMainContext(completion: @escaping () -> Void) {
        CoreData.mainContext.performAndWait {
            do {
                try CoreData.mainContext.save()
                saveMasterContext()
            } catch {
                print(error)
            }
//            DispatchQueue.main.async {
                completion()
//            }
        }
    }
    
    static func saveMasterContext() {
        CoreData.masterContext.perform {
            do {
                try CoreData.masterContext.save()
            } catch {
                print(error)
            }
        }
    }

    static var inserted: R {
        return R(context: CoreData.backContext)
    }
    
    static func clearIfNeeded(with key: String, value: String?, shouldClearObject: ObjectClearConfirmationHandler? = nil) -> [String: Any]? {

        if let value = value {
            if let confirmationHandler = shouldClearObject {
                if let object = fetch(with: key, value: value) {
                    let dictToSave = confirmationHandler(object)
                    clearObject(with: key, value: value)
                    return dictToSave
                } else { _ = confirmationHandler(nil) }
            } else {
                if exististsObject(with: key, value: value) {
                    clearObject(with: key, value: value)
                }
            }
        } else {
            print("no value for key: \(key) for \(String(describing: R.self))")
        }
        return nil
    }
    
    static func clearAllObjects() {
        let context = CoreData.backContext
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        do {
            let objects = try context.fetch(fetchRequest)
            _ = objects.map { context.delete($0) }
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
    
    static func clearObject(with key: String, value: String?) {
        let context = CoreData.backContext
        guard let value = value else { return }
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = NSPredicate(format: "\(key) == %@", value)
        do {
            let objects = try context.fetch(fetchRequest)
            _ = objects.map { context.delete($0) }
        } catch let error {
            print("ERROR DELETING : \(error)")
        }
    }
    
    static func fetch(with key: String, value: String?) -> R? {
        guard let value = value else { return nil }
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = NSPredicate(format: "\(key) == %@", value)
        do {
            let object = try CoreData.backContext.fetch(fetchRequest).first
            return object
        } catch { print(error); return nil }
    }
    
    static func fetch(with predicate: NSPredicate) -> R? {
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = predicate
        do {
            let object = try CoreData.backContext.fetch(fetchRequest).first
            return object
        } catch { print(error); return nil }
    }
    
    static func exististsObject(with key: String, value: String?) -> Bool {
        guard let value = value else { return false }
        let fetchRequest = NSFetchRequest<R>(entityName: String(describing: R.self))
        fetchRequest.predicate = NSPredicate(format: "\(key) == %@", value)
        do {
            let count = try CoreData.backContext.count(for: fetchRequest)
            return count > 0
        } catch { print(error); return false }
    }
}

class DataController: NSObject {
    static let main = DataController()
    private override init() {}
    
    func printLibraryPath() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print("vvvv")
            print(url.path)
            print("^^^^")
        }
    }
    
    // MARK: - Core Data stack
    fileprivate var _backgroundContext: NSManagedObjectContext?
    var backgroundContext: NSManagedObjectContext {
        if let backgroundContext = self._backgroundContext {
            return backgroundContext
        } else {
            let new = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            new.parent = CoreData.mainContext
            self._backgroundContext = new
            return _backgroundContext!
        }
    }
    
    fileprivate var _mainContext: NSManagedObjectContext?
    var mainContext: NSManagedObjectContext {
        if let mainContext = self._mainContext {
            return mainContext
        } else {
            let new = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            new.parent = CoreData.masterContext
            self._mainContext = new
            return _mainContext!
        }
    }
    
    fileprivate var _masterContext: NSManagedObjectContext?
    var masterContext: NSManagedObjectContext {
        if let masterContext = self._masterContext {
            return masterContext
        } else {
            let new = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            new.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
            self._masterContext = new
            return _masterContext!
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let name = "RCDataModel"
        print("bundle: \(bundle)")
        guard let modelURL = bundle?.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Unable to locate Core Data model")
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: mom)
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
    var day: (Date, NSMutableOrderedSet)? { get }
    var dayValue: (Date, NSMutableOrderedSet) { get }
    var dictToSave: [String: Any]? { get set }
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
    var day: (Date, NSMutableOrderedSet)? {
        return container as? (Date, NSMutableOrderedSet)
    }
    var dayValue: (Date, NSMutableOrderedSet) {
        return container as? (Date, NSMutableOrderedSet) ?? (Date(), NSMutableOrderedSet())
    }
}

struct DictInsertion: Insertion {
    var type: InsertionType
    var container: Any
    var dictToSave: [String: Any]?
    init(_ dict: [String: Any], dictToSave: [String: Any]? = nil) {
        self.container = dict
        self.type = .dict
        self.dictToSave = dictToSave
    }
}

struct StringInsertion: Insertion {
    var type: InsertionType
    var container: Any
    var dictToSave: [String: Any]?
    init(_ string: String, dictToSave: [String: Any]? = nil) {
        self.container = string
        self.type = .string
        self.dictToSave = dictToSave
    }
}

struct DayInsertion: Insertion {
    var type: InsertionType
    var container: Any
    var dictToSave: [String: Any]?
    init(_ day: (Date, NSMutableOrderedSet), dictToSave: [String: Any]? = nil) {
        self.container = day
        self.type = .day
        self.dictToSave = dictToSave
    }
}

struct Unwrap<R: NSFetchRequestResult> {
    static func arrayFromSet(_ set: NSOrderedSet?) -> [R]? {
        return set.unwrapped()
    }
    
    static func arrayValueFromSet(_ set: NSOrderedSet?) -> [R] {
        return set.unwrappedValue()
    }
}

extension Optional where Wrapped: NSOrderedSet {
    func unwrapped<R: NSFetchRequestResult>() -> [R]? {
        switch self {
        case .some(let wrapped):
            return wrapped.array as? [R]
        default: break
        }
        return nil
    }
    
    func unwrappedValue<R>() -> [R] {
        switch self {
        case .some(let wrapped):
            if let array = wrapped.array as? [R] {
                return array
            }
        default: break
        }
        return [R]()
    }
}

extension Optional {
    func maybeInsertDictArray<R: NSFetchRequestResult>(_ insertion: @escaping (Insertion) -> R?) -> NSMutableOrderedSet? {
        if let array = jsonArray {
            return NSMutableOrderedSet(array: array.flatMap {
                return insertion(DictInsertion($0))
            })
        } else { return nil }
    }
    
    func maybeInsertDictObject<R: NSFetchRequestResult>(_ insertion: (Insertion) -> R?) -> R? {
        if let json = json {
            return insertion(DictInsertion(json))
        } else { return nil }
    }
    
    func maybeInsertStringArray<R: NSFetchRequestResult>(_ insertion: (Insertion) -> R?) -> NSMutableOrderedSet? {
        if let array = stringArray {
            return NSMutableOrderedSet(array: array.flatMap {
                return insertion(StringInsertion($0))
            })
        } else { return nil }
    }
    
    func maybeInsertStringObject<R: NSFetchRequestResult>(_ insertion: (Insertion) -> R?) -> R? {
        if let string = string {
            return insertion(StringInsertion(string))
        } else { return nil }
    }
}
