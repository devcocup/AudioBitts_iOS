//
//  ABUserManager.swift
//  AudioBitts
//
//  Created by Ashok on 30/03/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import Foundation
import Parse
import GoogleSignIn

class ABUserManager {
    
    static let sharedInstance = ABUserManager()
    
    //    var currentUser: ABUser?
    
    func logOut() {
        guard let user = PFUser.current() else { print("No User found to logout."); return }
        PFUser.logOut()
        
        destoryInfo()
        
        // Loggingout Others
        guard let userName = user.username else {return;}
        if userName.contains("Google:") { GIDSignIn.sharedInstance().signOut() }
    }
    
    func refreshCurrentUser(_ completionHandler: ((_ errorInformation: String?) -> Void)? = nil) {
        PFUser.current()?.fetchInBackground(block: { (object, error) -> Void in
            if error != nil {
                print("Error in refreshInBackgroundWithBlock: \(error?.localizedDescription)")
                if let completionHandler = completionHandler {
                    completionHandler(nil)
                }
            } else {
                if let completionHandler = completionHandler {
                    completionHandler(error?.localizedDescription)
                }
            }
        })
    }
    
    // Block and Unblock
    func checkInBlockedUsers(_ user: ABUser?, isInBlockedByColumn: Bool? = nil) -> Bool {
        if user == nil { return false }
        let currentUser = ABUser(pfUser: PFUser.current()!)
        
        if let usersList = isInBlockedByColumn == true ? currentUser.users_BlockdBy : currentUser.users_Blocked {
            for item in usersList {
                if item.objectId == user?.objectId {
                    return true
                }
            }
        }
        return false
    }
    
    
    fileprivate func destoryInfo() {
        SharedManager.sharedInstance.notificationCount = 0
        //        ABUserManager.sharedInstance.currentUser = nil
    }
}
