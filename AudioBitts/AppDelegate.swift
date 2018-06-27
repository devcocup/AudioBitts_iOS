//
//  AppDelegate.swift
//  AudioBitts
//
//  Created by Phani on 12/18/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import Social
import Accounts
import ParseFacebookUtilsV4
import ParseTwitterUtils
import TwitterKit
import FirebaseCore
import GoogleSignIn
import GoogleMobileAds

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        parseIntilaizersSetup(launchOptions)
        
        dealWithCurrentUser()
        configureSWRevealVC()
        //        sleep(10)
        // Override point for customization after application launch.
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        /*Intilazers setup*/
        
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        
        
        PFUser.enableRevocableSessionInBackground()
        //featch all user names
        HeyParse.sharedInstance.findAllBitUsernames()
        HeyParse.sharedInstance.getAppConfiguration()
        dealWithGoogleInitializers()
        TWTRTwitter.sharedInstance().start(withConsumerKey: "BOw5YRP7tma7y0FqEJsKSaJSe", consumerSecret: "A1AF43pD5yYjaQ3JdfB6D416ebapaKERK5uodfHI1Tvfd")
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.absoluteString.contains("twitterkit") {
            return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        } else if (url.scheme?.isEqual("926568520761942"))! {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url,
                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?,
                annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        } else {
            return GIDSignIn.sharedInstance().handle(url,
                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?,
                annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.AudioBittsInc.AudioBitts.createBitt" {
            if PFUser.current() == nil {
                SharedManager.sharedInstance.setContentVC("SignUpVC_ID")
            } else {
                SharedManager.sharedInstance.isCreateBittAutomatic = true
                SharedManager.sharedInstance.setContentVC("ExploreVC_ID")
            }
            completionHandler(true)
        }
        completionHandler(false)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Some fix in Master
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Clear Notifications
        clearNotifications()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
        // Clear Notifications
        clearNotifications()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Remote notifiactions
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let currentInstallation = PFInstallation.current()
        currentInstallation?.setDeviceTokenFrom(deviceToken)
        currentInstallation?.channels = ["global"]
        currentInstallation?.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == UIApplicationState.active { } else {
            PFPush.handle(userInfo)
            HeyParse.sharedInstance.getUserNotificationsCount()
        }
    }
    
    //MARK ------------
    
    func clearNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func dealWithCurrentUser() {
        if let user = PFUser.current() {
            ABUserManager.sharedInstance.refreshCurrentUser()
            //            ABUserManager.sharedInstance.currentUser = ABUser(pfUser: user)
        }
    }
    
    func configureSWRevealVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        //        let frontVC = UINavigationController(rootViewController: storyBoard.instantiateViewControllerWithIdentifier("NotificationsVC_ID"))
        
        let frontVC = UINavigationController(rootViewController: storyBoard.instantiateViewController(withIdentifier: "ExploreVC_ID"))
        let rearVC = storyBoard.instantiateViewController(withIdentifier: "SideMenuVC")
        
        let mainRevealController = SWRevealViewController(rearViewController: rearVC, frontViewController: frontVC)
        SharedManager.sharedInstance.revealVCInstance = mainRevealController
        
        window?.rootViewController = mainRevealController
        window?.makeKeyAndVisible()
    }
    
    func parseIntilaizersSetup(_ launchOptions: [AnyHashable: Any]?) {
        /* Previous configuration
        // Production: "AudioBitts"
        Parse.setApplicationId("tKgmfirf66vcdEO5fl7fkS1i5OS5R4mPL5O1fhmq", clientKey: "QgMumTXOs2Dctf4MCWrkBaKFk01tQqnSN5hy1Bpe")
        
        // Staging: "AudioBitts_Staging"
        Parse.setApplicationId("eSsTd9lfLODGAjYvzTFSi6HrTSMT5gjkveSgkuZ8", clientKey: "5Ivbuf4BfMQCYddbrgFQIPpbhGzmWl2kX6FTK5Mn")
        */
        
        // Production: "AudioBitts"
        // Setting up Parse custom server urls 23-May-2017
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "tKgmfirf66vcdEO5fl7fkS1i5OS5R4mPL5O1fhmq"
            ParseMutableClientConfiguration.clientKey = "QgMumTXOs2Dctf4MCWrkBaKFk01tQqnSN5hy1Bpe"
            ParseMutableClientConfiguration.server = "http://audiobits.us-east-1.elasticbeanstalk.com/parse"
        })
        
        Parse.initialize(with: parseConfiguration)
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        PFTwitterUtils.initialize(withConsumerKey: "BOw5YRP7tma7y0FqEJsKSaJSe",  consumerSecret:"7VLGO7qnf6fvXn0bp8EZWdoAY11JX9is7C8gfqqMkvjVOz7hgl")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    // MARK:- ---> Google
    
    func dealWithGoogleInitializers() {
        //        HeyGoogle.initializeMapKitAPIKey()
        //initilizeGoogleAnalytics()
        FIRApp.configure()
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1702501497314185/3087475803")
        
    }
    
//    func initilizeGoogleAnalytics(){
//        // Configure tracker from GoogleService-Info.plist.
//        var configureError:NSError? = nil
//        
//        GGLContext.sharedInstance().configureWithError(&configureError)
//        assert(configureError == nil, "Error configuring Google services: \(configureError)")
//        
//        // Optional: configure GAI options.
//        let gai = GAI.sharedInstance()
//        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
//        gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
//    }
    // MARK: Google <---
    
}

