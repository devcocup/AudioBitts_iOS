//
//  SharedManager.swift
//  Potholes
//
//  Created by Navya on 16/12/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit

@objc class SharedManager: NSObject {
    
    static let sharedInstance = SharedManager()
    
    var canShowLikePopUp = true
    //Current user deatials =
    var allBitUserNames = [String]()
    var notificationCount = 0 {
        didSet {
            DispatchQueue.main.async { () -> Void in
                notifyUserActivityNotificationsListeners()
            }
        }
    }
    var revealVCInstance: SWRevealViewController!
    var isCreateBittAutomatic = false
    
    //Config varibles
    var  privacyPolicy     = "Privacy Policy"
    var  feedbackEmail     = "feedback@audiobitts.com"
    var  errorReportMail   = "support@audiobitts.com"
    var  reportAbuseMail   = "support@audiobitts.com"
    var termsAndConditions = "support@audiobitts.com"
    var attributionText = "All the third party tools/libraries used for this App are open source. No licensed or copyrighted libraries have been used."
    
    
    func foundUserSignUp() {
        print("user signed Up")
    }
    
    func setContentVC(_ storyBoardID: String) {
        if revealVCInstance != nil {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let secondViewController = storyBoard.instantiateViewController(withIdentifier: storyBoardID)
            let navController = UINavigationController(rootViewController: secondViewController)
            secondViewController.view.addGestureRecognizer(revealVCInstance.panGestureRecognizer())
            revealVCInstance.pushFrontViewController(navController, animated:true)
        }
    }
    
}
