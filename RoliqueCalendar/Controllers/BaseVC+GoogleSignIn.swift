//
//  BaseVC+GoogleSignIn.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/26/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import GoogleSignIn

extension BaseVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            // let userId = user.userID                  // For client-side use only!
            // let idToken = user.authentication.idToken // Safe to send to the server
            // let fullName = user.profile.name
            // let givenName = user.profile.givenName
            // let familyName = user.profile.familyName
            // let email = user.profile.email
            // ...
            observeTokenCompletion?(user.authentication.accessToken)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

extension BaseVC: GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
