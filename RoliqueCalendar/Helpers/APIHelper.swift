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

// MARK: Configuration
extension APIHelper {
    static let isDebug = true
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
        requestFromGoogleAPI(owner: owner, router: .getEventList(calendarId: calendarId), completion: handleResponce(forObject: owner, completion: completion))
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
            
            if isDebug {
                print(">>>>>>>>>>")
                print("\nAPIHelper request with url:\n[\(router.urlString)]\n")
                print("<<<<<<<<<<")
            }
            
            let request = NSMutableURLRequest(url: NSURL(string: router.urlString)! as URL,
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
                    if let json = serialized?["items"] as? [[String: Any]] {
                        DispatchQueue.main.async {
                            let string = json.map { GModel(dict: $0)?.dictDescription ?? "" }.reduce(with: ",\n\n")
                            if isDebug {
                                print(">>>>>>>>>>")
                                print("\nAPIHelper received objects:\n[\(string)]\n")
                                print("<<<<<<<<<<")
                            }
                            completion(json)
                        }
                    } else if let errorDict = serialized?["error"] as? [String: Any] {
                        guard let errorModel = GErrorModel(dict: errorDict) else { return }
                        handleErrorString(errorModel.dictNoNilDescription, with: owner)
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
                    if let json = serialized {
                        DispatchQueue.main.async {
                            if isDebug {
                                print(">>>>>>>>>>")
                                print("\nAPIHelper received object:\n\(GModel(dict: json)?.dictDescription ?? "")\n")
                                print("<<<<<<<<<<")
                            }
                            completion(json)
                        }
                    } else if let errorDict = serialized?["error"] as? [String: Any] {
                        guard let errorModel = GErrorModel(dict: errorDict) else { return }
                        handleErrorString(errorModel.dictNoNilDescription, with: owner)
                    }
                }
            } else {
                handleErrorString("no data", with: owner)
            }
        }
    }
    
    static func handleErrorString(_ errStr: String, with owner: GoogleAPICompatible) {
        if isDebug {
            print(">>>>>>>>>>")
            print("\nAPIHelper got an errror:\n\(errStr)\n")
            print("<<<<<<<<<<")
        }
        owner.displayError(errStr)
    }
}
