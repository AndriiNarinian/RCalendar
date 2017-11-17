//
//  RCalendar.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 10/3/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

typealias RCalendarCalendarsCompletion = ([Calendar]) -> Void
typealias RCalendarEventsCompletion = ([Event]) -> Void
typealias RCalendarCompletion = () -> Void

open class RCalendar {
    static let main = RCalendar()
    fileprivate init() {}
    
    var calendarIds = [String]()
    var selectedCalendarIds = [String]()
    var bounds: (max: Date, min: Date)? {
        didSet {
            print("max: \(String(describing: bounds?.max)), min: \(String(describing: bounds?.min))")
        }
    }
    var minDate = defaultMinDate
    var maxDate = defaultMaxDate
    var bound: PaginationBound?
    var isLoading = false
    
    fileprivate var operationQ: OperationQueue?
    
    func cancelEventsFetching() {
       operationQ?.cancelAllOperations()
    }
    
    func startForCurrentUser(withOwner owner: GoogleAPICompatible?, calendarListCompletion: RCalendarCompletion? = nil, completion: @escaping RCalendarCompletion, onError: RCalendarCompletion? = nil) {
        let operation = Operation()
        operation.main()
        
        CalendarList.fetch(for: owner, completion: { calendarIds in
            self.calendarIds = calendarIds
            calendarListCompletion?()
            
            self.operationQ = OperationQueue()
            self.operationQ?.addOperation(FetchEventsOperation(calendarIds: calendarIds, owner: owner, completion: completion, onError: onError))

        }, onError: onError)
        
    }
    
    func loadEventsForCurrentCalendars(withOwner owner: GoogleAPICompatible, bound: PaginationBound? = nil, completion: @escaping RCalendarCompletion, onError: RCalendarCompletion? = nil) {
        if let bound = bound {
            switch bound {
            case .min:
                //top
                if let preMin = RCalendar.main.bounds?.min {
                    minDate = preMin.addingTimeInterval(-kEventFetchTimeInterval).withoutTime
                    maxDate = preMin
                }
            case .max:
                if let preMax = bounds?.max {
                    minDate = preMax
                    maxDate = preMax.addingTimeInterval(kEventFetchTimeInterval).withoutTime
                }
            }
        }
        
        self.operationQ = OperationQueue()
        
        self.operationQ?.addOperation(FetchEventsOperation(calendarIds: calendarIds, owner: owner, bound: bound, completion: completion, onError: onError))
    }
}

public extension RCalendar {
    static func initialize(with key: String) {
        APIHelper.configureGoogleAPI(with: key)
    }
    static func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return APIHelper.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    static func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return APIHelper.application(app, open: url, options: options)
    }
    static func googleSignIn() {
        APIHelper.signIn()
    }
    static func googleSignOut() {
        APIHelper.signOut()
        main.calendarIds = []
        NotificationCenter.default.post(name: NSNotification.Name("rolique-calendar-sign-out"), object: nil)
    }
}

fileprivate class FetchEventsOperation: AsyncOperation {
    var calendarIds: [String]
    weak var owner: GoogleAPICompatible?
    var bound: PaginationBound?
    var completion: RCalendarCompletion?
    var onError: RCalendarCompletion?
    let operationQ = OperationQueue()

    init(calendarIds: [String], owner: GoogleAPICompatible?, bound: PaginationBound? = nil, completion: RCalendarCompletion?, onError: RCalendarCompletion?) {
        self.calendarIds = calendarIds
        self.owner = owner
        self.bound = bound
        self.completion = completion
        self.onError = onError
        super.init()
        self.operationQ.qualityOfService = .userInteractive
    }
    
    override func cancel() {
        super.cancel()
        
        operationQ.cancelAllOperations()
    }
    
    override func main() {
        super.main()
        RCalendar.main.isLoading = true
        if isCancelled { return }
        
        calendarIds.forEach { id in
            let op = FetchEventsForCalendarOperation(calendarId: id, owner: owner, bound: bound, onError: onError)
            operationQ.addOperation(op)
        }
        operationQ.waitUntilAllOperationsAreFinished()
        print("FetchEventsOperation finished")
        self.finish()
        self.completion?()
        RCalendar.main.isLoading = false
    }
}

fileprivate class FetchEventsForCalendarOperation: AsyncOperation {
    var calendarId: String
    weak var owner: GoogleAPICompatible?
    var bound: PaginationBound?
    var onError: RCalendarCompletion?
    
    init(calendarId: String, owner: GoogleAPICompatible?, bound: PaginationBound?, onError: RCalendarCompletion?) {
        self.calendarId = calendarId
        self.owner = owner
        self.bound = bound
        self.onError = onError
        super.init()
    }
  
    override func cancel() {
        super.cancel()
        finish()
    }
    
    override func main() {
        super.main()
        if isCancelled { return }
        Event.all(
            calendarId: calendarId,
            for: owner, bound: self.bound,
            cancellationHandler: {
                return self.isCancelled },
            completion: {
                guard !self.isCancelled else { return }
                self.finish() },
            onError: onError
        )
    }
}

fileprivate class AsyncOperation: Operation {
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
}

fileprivate extension AsyncOperation {
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        main()
        state = .executing
    }
    
    func finish() {
        state = .finished
    }
}
