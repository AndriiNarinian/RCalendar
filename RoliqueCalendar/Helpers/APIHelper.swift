//
//  APIHelper.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import Foundation
import GoogleSignIn

typealias APICompletion = ([String: Any]) -> Void
typealias APICompletionArray = ([[String: Any]]) -> Void

enum DebugMode { case none, short, full }

// MARK: Configuration
extension APIHelper {
    static let debugMode: DebugMode = .short
    static func configureGoogleAPI(with key: String) {
        GIDSignIn.sharedInstance().scopes = [
            "https://www.googleapis.com/auth/calendar",
            "https://www.googleapis.com/auth/calendar.readonly",
            "https://www.googleapis.com/auth/plus.login"
        ]
        GIDSignIn.sharedInstance().clientID = key
    }
    
    static func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    static func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance()
            .handle(url,
                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                    annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
}

enum PaginationBound { case max, min }

// MARK: Public
open class APIHelper {
    static func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    static func signOut() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    static func getExtendedCalendars(owner: GoogleAPICompatible?, completion: @escaping APICompletionArray, onError: RCalendarCompletion? = nil) {
        requestFromGoogleAPI(owner: owner, router: .getExtendedCalendarList, completion: handleResponce(forArray: owner, completion: completion, onError: onError))
    }
    
    static func getExtendedCalendarList(owner: GoogleAPICompatible?, completion: @escaping APICompletion, onError: RCalendarCompletion? = nil) {
        requestFromGoogleAPI(owner: owner, router: .getExtendedCalendarList, completion: handleResponce(forObject: owner, completion: completion, onError: onError))
    }
    
    static func getExtendedCalendar(with id: String?, for owner: GoogleAPICompatible?, completion: @escaping APICompletion, onError: RCalendarCompletion? = nil) {
        guard let id = id else { owner?.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getExtendedCalendar(id: id), completion: handleResponce(forObject: owner, completion: completion, onError: onError))
    }
    
    static func getCalendar(with id: String?, for owner: GoogleAPICompatible?, completion: @escaping APICompletion, onError: RCalendarCompletion? = nil) {
        guard let id = id else { owner?.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getCalendar(id: id), completion: handleResponce(forObject: owner, completion: completion, onError: onError))
    }
    
    static func getEventList(with calendarId: String?, for owner: GoogleAPICompatible?, bound: PaginationBound? = nil, completion: @escaping APICompletion, onError: RCalendarCompletion? = nil) {
        guard let calendarId = calendarId else { owner?.displayError("calendar id is missing"); return }

        let params: Parameters = [
            "singleEvents": "true",
            "timeMax": Formatters.gcFormat.string(from: RCalendar.main.maxDate),
            "timeMin": Formatters.gcFormat.string(from: RCalendar.main.minDate)
        ]
        getAllPages(with: calendarId, for: owner, parameters: params, completion: { dict in
            let sortedAllDays = dict["items"].jsonArrayValue.map { dict -> Date? in
                let date = Formatters.gcFormatDate.date(from: (dict["start"].jsonValue["date"] as? String).stringValue)
                let dateTime = Formatters.gcFormatTz.date(from: (dict["start"].jsonValue["dateTime"] as? String).stringValue)
                
                return dateTime ?? date
                }.flatMap { $0 }.sorted(by: { $0 > $1 })
            if let bound = bound, let _ = sortedAllDays.first?.withoutTime, let _ = sortedAllDays.last?.withoutTime {
                switch bound {
                case .max:
                    let maxBound = RCalendar.main.maxDate
                    let minBound = RCalendar.main.bounds?.min ?? defaultMinDate
                    let bounds = (maxBound, minBound)
                    RCalendar.main.bounds = bounds
                case .min:
                    let maxBound = RCalendar.main.bounds?.max ?? defaultMaxDate
                    let minBound = RCalendar.main.minDate
                    let bounds = (maxBound, minBound)
                    RCalendar.main.bounds = bounds
                }
            } else {
                RCalendar.main.bounds = (RCalendar.main.bounds?.max ?? defaultMaxDate, RCalendar.main.bounds?.min ?? defaultMinDate)
                
            }
            
            completion(dict)
        }, onError: onError)
    }
    
    static func getAllPages(with calendarId: String?, for owner: GoogleAPICompatible?, parameters: Parameters, transferDict: [String: Any]? = nil, nextPageToken: String? = nil, completion: @escaping APICompletion, onError: RCalendarCompletion? = nil) {
        guard let calendarId = calendarId else { owner?.displayError("calendar id is missing"); return }
        var parameters = parameters
        if let nextPageToken = nextPageToken {
            parameters["pageToken"] = nextPageToken
        }
        let router: Router = .getEventList(calendarId: calendarId, parameters: parameters)
        
        requestFromGoogleAPI(owner: owner, router: router, completion: handleResponce(forObject: owner, completion: { dict in
            
            var transferDct = transferDict
            var existingItems = transferDct?["items"] as? [[String: Any]] ?? [[String: Any]]()
            let newItems = dict["items"] as? [[String: Any]] ?? [[String: Any]]()
            existingItems.append(contentsOf: newItems)
            transferDct?["items"] = existingItems
            let trnsfrDict = transferDct ?? dict

            if let nextPageToken = dict["nextPageToken"] as? String {
                getAllPages(with: calendarId, for: owner, parameters: parameters, transferDict: trnsfrDict, nextPageToken: nextPageToken, completion: completion)
            } else {
                completion(trnsfrDict)
            }
        }, onError: onError))
    }
    
    static func getEvent(with calendarId: String?, eventId: String?, for owner: GoogleAPICompatible, completion: @escaping APICompletion, onError: RCalendarCompletion? = nil) {
        guard let calendarId = calendarId, let eventId = eventId else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getEvent(calendarId: calendarId, eventId: eventId), completion: handleResponce(forObject: owner, completion: completion, onError: onError))
    }
}

// MARK: Private
fileprivate extension APIHelper {
    
    static func requestFromGoogleAPI(owner: GoogleAPICompatible?, router: Router, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        getAccessToken(owner: owner) { token in
            let headers = [
                "authorization": "Bearer \(token)"
            ]
            
            let url = router.urlEncodedWithParameters!
            
            if (debugMode == .short) || (debugMode == .full) {
                print(">>>>>>>>>>")
                print("\nAPIHelper request with url:\n[\(url)]\n")
                print("<<<<<<<<<<")
            }
            
            let request = NSMutableURLRequest(url: url,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = router.method.rawValue
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: completion)
            
            dataTask.resume()
        }
    }
    
    static func getAccessToken(owner: GoogleAPICompatible?, completion: @escaping (String) -> Void) {
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            completion(currentUser.authentication.accessToken)
        } else {
            GIDSignIn.sharedInstance().delegate = owner?.gIDSignInProxy
            GIDSignIn.sharedInstance().uiDelegate = owner?.gIDSignInProxy
            owner?.observeToken(completion: { token in
                completion(token)
            })
        }
    }
    
    static func handleResponce(forArray owner: GoogleAPICompatible?, completion: @escaping APICompletionArray, onError: RCalendarCompletion? = nil) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, responce, error in
            if let error = error {
                handleErrorString(error.localizedDescription, with: owner)
                onError?()
            } else if let data = data {
                if let serialized = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errorDict = serialized?["error"] as? [String: Any] {
                        guard let errorModel = GErrorModel(dict: errorDict) else { return }
                        handleErrorString(errorModel.dictNoNilDescription, with: owner)
                        onError?()
                    } else if let json = serialized?["items"] as? [[String: Any]] {
                        let string = json.map { GModel(dict: $0)?.dictDescription ?? "" }.reduce(with: ",\n\n")
                        if debugMode == .full {
                            print(">>>>>>>>>>")
                            print("\nAPIHelper received objects:\n[\(string)]\n")
                            print("<<<<<<<<<<")
                        }
                        DispatchQueue.main.async {
                            completion(json)
                        }
                    }
                }
            } else {
                handleErrorString("no data", with: owner)
                onError?()
            }
        }
    }
    
    static func handleResponce(forObject owner: GoogleAPICompatible?, completion: @escaping APICompletion, onError: RCalendarCompletion? = nil) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, responce, error in
            if let error = error {
                handleErrorString(error.localizedDescription, with: owner)
                onError?()
            } else if let data = data {
                if let serialized = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errorDict = serialized?["error"] as? [String: Any] {
                        guard let errorModel = GErrorModel(dict: errorDict) else { return }
                        handleErrorString(errorModel.dictNoNilDescription, with: owner)
                        onError?()
                    } else if let json = serialized {
                        if debugMode == .full {
                            print(">>>>>>>>>>")
                            print("\nAPIHelper received object:\n\(GModel(dict: json)?.dictDescription ?? "")\n")
                            print("<<<<<<<<<<")
                        }
                        DispatchQueue.main.async {
                            completion(json)
                        }
                    }
                }
            } else {
                handleErrorString("no data", with: owner)
                onError?()
            }
        }
    }
    
    static func handleErrorString(_ errStr: String, with owner: GoogleAPICompatible?) {
        if (debugMode == .short) || (debugMode == .full) {
            print(">>>>>>>>>>")
            print("\nAPIHelper got an errror:\n\(errStr)\n")
            print("<<<<<<<<<<")
        }
        DispatchQueue.main.async {
            owner?.displayError(errStr)
        }
    }
}
