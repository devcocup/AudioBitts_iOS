//
//  TwitterHelper.swift
//  AudioBitts
//
//  Created by Ashok on 21/03/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import Foundation
import ParseTwitterUtils


class TwitterHelper {
    func doLogin(_ completionHandler : @escaping (_ loginInfo: LoginInfo?, _ errorInformation: String?) -> Void) {
        if isInternetAvailable() {
            PFTwitterUtils.logIn(block: { (user: PFUser?, error: Error?) in
                
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
                        print("User signed up and logged in with Twitter!")
                        let user = PFUser.current()!
                        if let fullname = PFTwitterUtils.twitter()?.screenName {
                            user["fullName"] = fullname
                        }
                        if let userId = PFTwitterUtils.twitter()?.userId {
                            user["twitterId"] = userId
                        }
                        user.saveInBackground()
                        completionHandler(.signUp, nil)
                    } else {
                        if !PFTwitterUtils.isLinked(with: user) {
                            PFTwitterUtils.linkUser(user, block: {
                                (succeeded: Bool?, error: Error?) -> Void in
                                if PFTwitterUtils.isLinked(with: user) {
                                    print("Woohoo, user logged in with Twitter!")
                                }
                            })
                        }
                        print("User logged in with Twitter!")
                        completionHandler(.login, nil)
                    }
                } else {
                    print("Uh oh. The user cancelled the Twitter login.")
                    completionHandler(nil, "User has cancelled the Twitter login.")
                }
            })
        } else {
            completionHandler(nil, "Internet is not available.")
        }
    }
}
