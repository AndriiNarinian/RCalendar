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
    static func getExtendedCalendars(owner: BaseVC, completion: @escaping APICompletionArray) {
        requestFromGoogleAPI(owner: owner, router: .getExtendedCalendars, completion: handleResponce(forArray: owner, completion: completion))
    }
    
    static func getExtendedCalendar(with id: String?, for owner: BaseVC, completion: @escaping APICompletion) {
        guard let id = id else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getExtendedCalendar(id: id), completion: handleResponce(forObject: owner, completion: completion))
    }
    
    static func getCalendar(with id: String?, for owner: BaseVC, completion: @escaping APICompletion) {
        guard let id = id else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getCalendar(id: id), completion: handleResponce(forObject: owner, completion: completion))
    }
    
    static func getEvents(with calendarId: String?, for owner: BaseVC, completion: @escaping APICompletionArray) {
        guard let calendarId = calendarId else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getEvents(calendarId: calendarId), completion: handleResponce(forArray: owner, completion: completion))
    }
    
    static func getEvent(with calendarId: String?, eventId: String?, for owner: BaseVC, completion: @escaping APICompletion) {
        guard let calendarId = calendarId, let eventId = eventId else { owner.displayError("calendar id is missing"); return }
        requestFromGoogleAPI(owner: owner, router: .getEvent(calendarId: calendarId, eventId: eventId), completion: handleResponce(forObject: owner, completion: completion))
    }
}

// MARK: Private
fileprivate extension APIHelper {
    static let kClientID = "343892928011-4ibhevkj1jabjk527b4rhnve41995e1p.apps.googleusercontent.com"
    
    static func signIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    static func signOut() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    static func requestFromGoogleAPI(owner: BaseVC, router: Router, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        getAccessToken(owner: owner) { token in
            let headers = [
                "authorization": "Bearer \(token)"
            ]
            
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
    
    static func getAccessToken(owner: BaseVC, completion: @escaping (String) -> Void) {
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            completion(currentUser.authentication.accessToken)
        } else {
            GIDSignIn.sharedInstance().delegate = owner
            GIDSignIn.sharedInstance().uiDelegate = owner
            owner.observeToken(completion: { token in
                completion(token)
            })
        }
    }
    
    static func handleResponce(forArray owner: BaseVC, completion: @escaping APICompletionArray) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, responce, error in
            if let error = error {
                owner.displayError(error.localizedDescription)
            } else if let data = data {
                if let serialized = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let json = serialized?["items"] as? [[String: Any]] {
                        DispatchQueue.main.async {
                            completion(json)
                        }
                    } else if let errorDict = serialized?["error"] as? [String: Any] {
                        let errorModel = ErrorModel(dict: errorDict)
                        owner.displayError(errorModel.dictDescription)
                    }
                }
            } else {
                owner.displayError("unknown error")
            }
        }
    }
    
    static func handleResponce(forObject owner: BaseVC, completion: @escaping APICompletion) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, responce, error in
            if let error = error {
                owner.displayError(error.localizedDescription)
            } else if let data = data {
                if let serialized = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let json = serialized {
                        DispatchQueue.main.async {
                            completion(json)
                        }
                    } else if let errorDict = serialized?["error"] as? [String: Any] {
                        let errorModel = ErrorModel(dict: errorDict)
                        owner.displayError(String(describing: errorModel))
                    }
                }
            } else {
                owner.displayError("unknown error")
            }
        }
    }
}
