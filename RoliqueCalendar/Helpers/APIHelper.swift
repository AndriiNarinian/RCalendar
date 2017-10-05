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
    static func configureGoogleAPI() {
        GIDSignIn.sharedInstance().scopes = [
            "https://www.googleapis.com/auth/calendar",
            "https://www.googleapis.com/auth/calendar.readonly",
            "https://www.googleapis.com/auth/plus.login"
        ]
        GIDSignIn.sharedInstance().clientID = kClientID
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

// MARK: Public
class APIHelper {
    static func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    static func signOut() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    static func getExtendedCalendars(owner: GoogleAPICompatible, completion: @escaping APICompletionArray) {
        requestFromGoogleAPI(owner: owner, router: .getExtendedCalendarList, completion: handleResponce(forArray: owner, completion: completion))
    }
    
    static func getExtendedCalendarList(owner: GoogleAPICompatible, completion: @escaping APICompletion) {
        requestFromGoogleAPI(owner: owner, router: .getExtendedCalendarList, completion: handleResponce(forObject: owner, completion: completion))
    }
    
    static func getExtendedCalendar(with id: String?, for owner: GoogleAPICompatible, completion: @escaping APICompletion) {
        guard let id = id else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getExtendedCalendar(id: id), completion: handleResponce(forObject: owner, completion: completion))
    }
    
    static func getCalendar(with id: String?, for owner: GoogleAPICompatible, completion: @escaping APICompletion) {
        guard let id = id else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getCalendar(id: id), completion: handleResponce(forObject: owner, completion: completion))
    }
    
    static func getEventList(with calendarId: String?, for owner: GoogleAPICompatible, completion: @escaping APICompletion) {
        guard let calendarId = calendarId else { owner.displayError("calendar id is missing"); return }
        getAllPages(with: calendarId, for: owner, router: .getEventList(calendarId: calendarId, parameters: [:]), completion: completion)
    }
    
    static func getAllPages(with calendarId: String?, for owner: GoogleAPICompatible, router: Router, transferDict: [String: Any]? = nil, completion: @escaping APICompletion) {
        guard let calendarId = calendarId else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: router, completion: handleResponce(forObject: owner, completion: { dict in
            
            var transferDct = transferDict
            var existingItems = transferDct?["items"] as? [[String: Any]] ?? [[String: Any]]()
            let newItems = dict["items"] as? [[String: Any]] ?? [[String: Any]]()
            existingItems.append(contentsOf: newItems)
            transferDct?["items"] = existingItems
            let trnsfrDict = transferDct ?? dict
//            
//            print("transferDict: \((transferDict?["items"] as? [Any])?.count)")
//            print("dict: \((dict["items"] as? [Any])?.count)")
//            print("transferDct: \((transferDct?["items"] as? [Any])?.count)")
//            
            if let nextPageToken = dict["nextPageToken"] as? String {
                
                
                getAllPages(with: calendarId, for: owner, router: .getEventList(calendarId: calendarId, parameters: ["pageToken": nextPageToken]), transferDict: trnsfrDict, completion: completion)
            } else {
                completion(trnsfrDict)
            }
        }))
    }
    
    static func getEvent(with calendarId: String?, eventId: String?, for owner: GoogleAPICompatible, completion: @escaping APICompletion) {
        guard let calendarId = calendarId, let eventId = eventId else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getEvent(calendarId: calendarId, eventId: eventId), completion: handleResponce(forObject: owner, completion: completion))
    }
}

// MARK: Private
fileprivate extension APIHelper {
    static let kClientID = "343892928011-4ibhevkj1jabjk527b4rhnve41995e1p.apps.googleusercontent.com"
    static func requestFromGoogleAPI(owner: GoogleAPICompatible, router: Router, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
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
    
    static func getAccessToken(owner: GoogleAPICompatible, completion: @escaping (String) -> Void) {
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            completion(currentUser.authentication.accessToken)
        } else {
            GIDSignIn.sharedInstance().delegate = owner.gIDSignInProxy
            GIDSignIn.sharedInstance().uiDelegate = owner.gIDSignInProxy
            owner.observeToken(completion: { token in
                completion(token)
            })
        }
    }
    
    static func handleResponce(forArray owner: GoogleAPICompatible, completion: @escaping APICompletionArray) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, responce, error in
            if let error = error {
                handleErrorString(error.localizedDescription, with: owner)
            } else if let data = data {
                if let serialized = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errorDict = serialized?["error"] as? [String: Any] {
                        guard let errorModel = GErrorModel(dict: errorDict) else { return }
                        handleErrorString(errorModel.dictNoNilDescription, with: owner)
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
            }
        }
    }
    
    static func handleResponce(forObject owner: GoogleAPICompatible, completion: @escaping APICompletion) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, responce, error in
            if let error = error {
                handleErrorString(error.localizedDescription, with: owner)
            } else if let data = data {
                if let serialized = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errorDict = serialized?["error"] as? [String: Any] {
                        guard let errorModel = GErrorModel(dict: errorDict) else { return }
                        handleErrorString(errorModel.dictNoNilDescription, with: owner)
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
            }
        }
    }
    
    static func handleErrorString(_ errStr: String, with owner: GoogleAPICompatible) {
        if (debugMode == .short) || (debugMode == .full) {
            print(">>>>>>>>>>")
            print("\nAPIHelper got an errror:\n\(errStr)\n")
            print("<<<<<<<<<<")
        }
        DispatchQueue.main.async {
            owner.displayError(errStr)
        }
    }
}
