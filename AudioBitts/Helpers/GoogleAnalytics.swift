//
//  GoogleAnalytics.swift
//  Voler
//
//  Created by Manoj on 26/11/15.
//  Copyright © 2015 MobileWays. All rights reserved.
//

import Foundation
import Parse


//let GASN         = ""

let GASNIntro                = "INTRO-SCREEN"
let GASNMyBitts              = "MY BITTS-SCREEN"
let GASNHome                 = "HOME-SCREEN"
let GASNRateUs               = "RATE US-SCREEN"
let GASNNOtifications        = "NOTIFICATIONS-SCREEN"
let GASNSettings             = "SETTINGS-SCREEN"
let GASNSignUp               = "SIGNUP-SCREEN"
let GASNLogIn                = "LOGIN-SCREEN"
let GASNTellaFriend          = "TELL A FRIEND-SCREEN"
let GASNRecordBit            = "RECORD BITT-SCREEN"
let GASNSearch               = "SEARCH-SCREEN"
let GASNComment              = "COMMENT-SCREEN"
let GASNProfile              = "PROFILE-SCREEN"
let GASNPushNotifications    = "PUSHNOTIFICATION-SCREEN"
let GASNPushNotificationsSetting    = "PUSHNOTIFICATIONSETTINGS-SCREEN"
let GASNFeedBack             = "FEEDBACK-SCREEN"
let GASNPrivacyPolicy        = "PRIVACYPOLICY-SCREEN"
let GASNTermsAndConditions   = "TERMSANDCONDITIONS-SCREEN"
let GASNCreateAccount        = "CREATEACCOUNT-SCREEN"
let GASNForgot               = "FORGOT-SCREEN"
let GASNFollowers            = "FOLLOWERS-SCREEN"
let GASNFollowing            = "FOLLOWING-SCREEN"

//let GAEV         = ""

let GAEVGlobal               = "Global-EVENT"
let GAEVFollowing            = "Following-EVENT"
let GAEVPlay                 = "Play-EVENT"
let GAEVLike                 = "Like-EVENT"
let GAEVRecord               = "Record-EVENT"

let GAEVShare                = "Share-EVENT"
let GAEVReportAbuse          = "ReportAbuse-EVENT"

let GAEVNotificationLikes        = "Likes-EVENT"
let GAEVNotificationComments     = "Comments-EVENT"
let GAEVNotificationNewFollower  = "NewFollowers-EVENT"
let GAEVNotificationTags         = "Tags-EVENT"

let GAEVSignOut                  = "SignOut-EVENT"

let GAEVSignUp               = "SIGNUP-EVENT"
let GAEVGoogleSignUp         = "SignupWithGoogle"
let GAEVFacebookSignUp       = "SignupWithFacebook"
let GAEVEmailSignUp          = "SignupWithEmail"

let GAEVLogin                 = "LOGIN-EVENT"
let GAEVGoogleLogin           = "LoginWithGoogle"
let GAEVFacebookLogin         = "LoginWithFaceBook"
let GAEVTwitterLogin          = "LoginWithTwitter"
let GAEVEmailLogin            = "LoginWithEmail"

let GAEVAboutUs               = "ABOUTUS-EVENT"

let GAEVMenu                 = "MENU-EVENT"

let VLError                  = "Error"


let analyticsDispatchInterval = 120.0

extension UIViewController {
    
//    func trackScreen(_ name: String) {
//        self.sendScreenView(name)
//    }
//    
//    func sendScreenView(_ name: String) {
//        let tracker = GAI.sharedInstance().defaultTracker
//        setUserType()
//        tracker?.set(kGAIScreenName, value: name)
//        let builder = (GAIDictionaryBuilder.createScreenView().build() as NSDictionary) as! [AnyHashable: Any]
//        tracker?.send(builder)
//    }
//    
//    func trackEvent(_ category: String, action: String, label: String, value: NSNumber?) {
//        let tracker = GAI.sharedInstance().defaultTracker
//        setUserType()
//        let trackDictionary = (GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build() as NSDictionary) as! [AnyHashable: Any]
//        tracker?.send(trackDictionary)
//    }
//    
//    func onLoad(_ category: String, interval: NSNumber, name: String, label: String){
//        let tracker: AnyObject = GAI.sharedInstance().defaultTracker
//        let trackDictionary = (GAIDictionaryBuilder.createTiming(withCategory: category, interval: interval, name: name, label: label).build() as NSDictionary) as! [AnyHashable: Any]
//        tracker.send(trackDictionary)
//    }
//
//    
//    // sends the user id to Google Analytics
//    func setTrackedUserID(_ id: String) {
//        GAI.sharedInstance().defaultTracker.set("&uid", value: id)
//    }
//    
//    func setUserType() {
//        let tracker = GAI.sharedInstance().defaultTracker
//        if (PFUser.current() != nil) {
//            tracker?.set(GAIFields.customDimension(for: 1), value: "AUDIOBITT_USER")
//        } else {
//            tracker?.set(GAIFields.customDimension(for: 1), value: "ANONYMOUS_USER")
//        }
//    }
//    
//    //For Getting Exceptions And Crashes during fetching data from Server
//    func trackException(_ description: String, category: String, value: NSNumber) {
//    let tracker = GAI.sharedInstance().defaultTracker
//    let trackDictionary = (GAIDictionaryBuilder.createException(withDescription: description, withFatal: value).build() as NSDictionary) as! [AnyHashable: Any]
//    tracker?.send(trackDictionary)
//    }
//}
//
//extension UITableViewCell {
//    
//    func trackEvent(_ category: String, action: String, label: String, value: NSNumber?) {
//        let tracker = GAI.sharedInstance().defaultTracker
//        setUserType()
//        let trackDictionary = (GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build() as NSDictionary) as! [AnyHashable: Any]
//        tracker?.send(trackDictionary)
//    }
//    
//    // sends the user id to Google Analytics
//    func setTrackedUserID(_ id: String) {
//        GAI.sharedInstance().defaultTracker.set("&uid", value: id)
//    }
//    
//    func setUserType() {
//        let tracker = GAI.sharedInstance().defaultTracker
//        if (PFUser.current() != nil) {
//            tracker?.set(GAIFields.customDimension(for: 1), value: "AUDIOBITT_USER")
//        } else {
//            tracker?.set(GAIFields.customDimension(for: 1), value: "ANONYMOUS_USER")
//        }
//    }
}
