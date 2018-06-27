//
//  FacebookHelper.swift
//  AudioBitts
//
//  Created by Ashok on 21/03/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import Foundation

import ParseFacebookUtilsV4

enum LoginInfo {
    case signUp, login
}

class FacebookHelper {
    
    func doLogin(_ completionHandler : @escaping (_ loginInfo: LoginInfo?, _ errorInformation: String?) -> Void) {
        if isInternetAvailable() {
            // Log In with Read Permissions
            let permissions = ["public_profile"]
            PFFacebookUtils.logInInBackground(withReadPermissions: permissions, block: { (user: PFUser?, error: Error?) -> Void in
                
                //Register For Push notification
                if (error == nil) {
                    if let userdata =  PFUser.current() {
                        let currentInstallation = PFInstallation.current()
                        currentInstallation?["user"] = userdata
                        currentInstallation?["bitUsername"] = userdata["bitUsername"] ?? ""
                        currentInstallation?.saveInBackground()
                    }
                }
                if let user = user {
                    if user.isNew {
                        print("User signed up and logged in through Facebook!")
                        // Create request for user's Facebook data
                        let request = FBSDKGraphRequest(graphPath:"me", parameters:["fields": "id, name, first_name, last_name, picture.type(large), email"])
                        // Send request to Facebook
                        
                        _ = request?.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
                            
                            if error != nil {
                                print(error ?? "")
                            } else if let userData = result as? [String:AnyObject] {
                                // Access user data
                                let user = PFUser.current()!
                                user["email"] = userData["email"] as? String ?? ""
                                user["fullName"] = userData["name"] as? String ?? ""
                                user["facebookId"] = userData["id"] as? String ?? ""
                                //                if let picture = userData["picture"]?["data"]??["url"]{
                                //                  user["profilePic"] = picture as? String ?? ""
                                //                }
                                user.saveInBackground {
                                    (success: Bool, error: Error?) -> Void in
                                    if !success {
                                        let user = PFUser.current()!
                                        if (error?.localizedDescription == "203") { // the email address "test@test.com" has already been taken
                                            user.email = nil
                                        }
                                        user["fullName"] = userData["name"] as? String ?? ""
                                        user["facebookId"] = userData["id"] as? String ?? ""
                                        //                    if let picture = userData["picture"]?["data"]??["url"]{
                                        //                      user["profilePic"] = picture as? String ?? ""
                                        //                    }
                                        user.saveInBackground {
                                            (success: Bool, error: Error?) -> Void in
                                            print(success)
                                        }
                                    }
                                    print("Successfully logged in through Facebook")
                                    completionHandler(.signUp, nil)
                                }
                            }
                        })
                    } else {
                        print("User logged in through Facebook!")
                        completionHandler(.login, nil)
                    }
                } else {
                    completionHandler(nil, error?.localizedDescription ?? "User has cancelled the Facebook login.")
                    print(error?.localizedDescription ?? "Uh oh. The user cancelled the Facebook login.")
                }
            })
        } else {
            completionHandler(nil, "Internet is not available.")
        }
    }
}

