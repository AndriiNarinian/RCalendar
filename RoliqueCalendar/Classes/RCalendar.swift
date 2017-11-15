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
    var bounds: (max: Date, min: Date)?
    var minDate = defaultMinDate
    var maxDate = defaultMaxDate
    
    func startForCurrentUser(withOwner owner: GoogleAPICompatible, calendarListCompletion: RCalendarCompletion? = nil, completion: @escaping RCalendarCompletion, onError: RCalendarCompletion? = nil) {
        let operation = Operation()
        operation.main()
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        CalendarList.fetch(for: owner, completion: { calendarIds in
            self.calendarIds = calendarIds
            calendarListCompletion?()
            RCalendar.main.getEventsForCalendarsRecurcively(withOwner: owner, for: calendarIds, completion: {
                dispatchGroup.leave()
            }, onError: onError)
        }, onError: onError)
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion()
        }
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
        getEventsForCalendarsRecurcively(withOwner: owner, for: calendarIds, bound: bound, completion: completion, onError: onError)
    }
    
    fileprivate func getEventsForCalendarsRecurcively(withOwner owner: GoogleAPICompatible, for ids: [String], bound: PaginationBound? = nil, completion: @escaping RCalendarCompletion, onError: RCalendarCompletion? = nil) {
        var calendars = ids
        if calendars.count > 0 {
            let calendarId = calendars.removeFirst()
            Event.all(calendarId: calendarId, for: owner, bound: bound, completion: { [unowned self] in
                self.getEventsForCalendarsRecurcively(withOwner: owner, for: calendars, bound: bound, completion: completion, onError: onError)
            }, onError: onError)
        } else {
            completion()
        }
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

class FetchEventsOperation: Operation {
    var calendarIds: [String]
    
    init(calendarIds: [String]) {
        self.calendarIds = calendarIds
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        
        if isCancelled { return }
    }
}

class FetchEventOperation: Operation {
    var calendarIds: [String]
    weak var owner: GoogleAPICompatible?
    var bound: PaginationBound?
    var completion: RCalendarCompletion?
    var onError: RCalendarCompletion?
    
    init(calendarIds: [String], owner: GoogleAPICompatible?, bound: PaginationBound?, completion: RCalendarCompletion?, onError: RCalendarCompletion?) {
        self.calendarIds = calendarIds
        self.owner = owner
        self.bound = bound
        self.completion = completion
        self.onError = onError
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        guard let owner = owner, let completion = completion else { return }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchUnknownActors {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchUnknownItemImages {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchUnknownItemIdentifiers {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchUnknownGameModes {
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchUnknownSkins {
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if isFinal {
                AppConfig.current.finishedToFetchData = true
            }
            completion()
        }
        
        Event.all(calendarId: calendarId, for: owner, bound: bound, completion: completion, onError: onError)
    }
}

class PendingOperations {
    lazy var fetchingEvents = [Calendar: Operation]()
    lazy var fetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Event Fetch Queue"
        return queue
    }()
}
