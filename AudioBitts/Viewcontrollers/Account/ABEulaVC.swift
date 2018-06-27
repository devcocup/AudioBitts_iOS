//
//  ABEulaVC.swift
//  AudioBitts
//
//  Created by Ashok on 03/05/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import ParseTwitterUtils
import GoogleSignIn

enum ABSignUpType {
    case facebook, twitter, googlePlus, email
}

class ABEulaVC: BaseMainVC {
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    
    var signupType: ABSignUpType!
    var email: String?
    var userName: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "License Agreement"
        
        let path = Bundle.main.path(forResource: "AudioBitts_EULA", ofType: "txt")!
        do {
            contentTextView.text = try String(contentsOfFile: path)
        } catch { print("Error in contentsOfFile") }
        
        perform(#selector(adjustTextViewContextOffset), with: nil, afterDelay: 0)
        
        // Google Plus
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureBackButton() {
        addBackButton()
    }
    
    func adjustTextViewContextOffset() {
        contentTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func acceptBtnAction(_ sender: UIButton) {
        sender.isEnabled = false
        switch signupType! {
        case .facebook:
            self.handleFacebookSignUp()
        case .twitter:
            self.handleTwitterSignUp()
        case .googlePlus:
            self.handleGooglePlusSignUp()
        case .email:
            self.handleEmailSignUp()
        }
    }
    
    // MARK:- Facebook
    func handleFacebookSignUp() {
        showIndicator(blockUI: true)
        FacebookHelper().doLogin { (loginInfo, errorInformation) -> Void in
            self.hideIndicator()
            self.acceptButton.isEnabled = true
            if let loginInfo = loginInfo {
                switch loginInfo {
                case .signUp:
                    self.showCreateAccountVC()
                case .login:
                    //self.trackEvent(GAEVLogin, action: GAEVFacebookLogin, label: "FacebookSugnup", value: nil)
                    self.checkBitNameAvailability()
                }
            } else if let errorInformation = errorInformation {
                showAlert("Error!", message: errorInformation, on: self)
            }
        }
    }
    //
    
    // MARK:- Twitter
    
    func handleTwitterSignUp() {
        showIndicator(blockUI: true)
        TwitterHelper().doLogin { (loginInfo, errorInformation) -> Void in
            self.hideIndicator()
            self.acceptButton.isEnabled = true
            if let loginInfo = loginInfo {
                switch loginInfo {
                case .signUp:
                    self.getTwitterUserDetails()
                    self.showCreateAccountVC()
                case .login:
                    self.checkBitNameAvailability()
                    //self.trackEvent(GAEVSignUp, action: GAEVTwitterLogin, label: "TwittereLogin", value: nil)
                }
            } else if let errorInformation = errorInformation {
                showAlert("Error!", message: errorInformation, on: self)
            }
        }
    }
    
    func getTwitterUserDetails() {
        let twitterUserID = PFTwitterUtils.twitter()?.userId
        let twitterScreenName = PFTwitterUtils.twitter()?.screenName
        var twitterURL = "https://api.twitter.com/1.1/users/show.json?"
        if let userID = twitterUserID {
            twitterURL = twitterURL + "user_id=" + userID
        } else if let screenName = twitterScreenName {
            twitterURL = twitterURL + "screen_name=" + screenName
        } else {
            print("Something's not right")
            return
        }
        let verify = URL(string: twitterURL)
        let request = NSMutableURLRequest(url: verify!)
        PFTwitterUtils.twitter()?.sign(request)
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) { (response, data, error) in
            if error == nil {
                do {
                    let JSON = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                    guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                        print("Not a Dictionary")
                        // put in function
                        return
                    }
                    print("JSONDictionary! \(JSONDictionary)")
                    let user = PFUser.current()
                    
                    //                    let profileImage = JSONDictionary["profile_image_url_https"] as! String
                    //                    if !profileImage.isEmpty{
                    //                        user!["profileImageAvatar"] = profileImage
                    //                    }
                    
                    let screenName = JSONDictionary["screen_name"] as! String
                    //                    if !screenName.isEmpty{
                    //                        user!["screen_name"] = screenName
                    //                    }
                    
                    let userName = JSONDictionary["name"] as! String
                    if !userName.isEmpty {
                        user!["fullName"] = userName
                    } else if !screenName.isEmpty {
                        user!["fullName"] = screenName
                    }
                    user?.saveInBackground(block: { (status, error) -> Void in
                        if error == nil {
                            print("twitter data saved")
                        } else {
                            print("error saving twitter data")
                            print(error!)
                        }
                    })
                }
                catch let JSONError as Error {
                    print("\(JSONError)")
                }
            }
        }
    }
    //
    
    // MARK:- Google Plus
    func handleGooglePlusSignUp() {
        self.showIndicator()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    //
    
    // MARK:- Email
    func handleEmailSignUp() {
        if isInternetAvailable(true) {
            self.showIndicator()
            let usersinup:User = User()
            usersinup.name = ""
            usersinup.email = self.email!
            usersinup.username = self.userName!
            usersinup.pwd = self.password!
            
            HeyParse.sharedInstance.findDuplicates("email", value: "\(self.email!)", completionHandler: { (isFound, existedUserIdType) -> Void in
                self.hideIndicator()
                self.acceptButton.isEnabled = true
                if isFound {
                    showAlert("Please use \(existedUserIdType.lowercased()) login", message:"\(self.email!) already signed up with \(existedUserIdType)" , on: self)
                } else {
                    self.showIndicator()
                    self.showCreateAccountVC(usersinup)
                }
            })
        }
    }
    //
    
    // MARK:- Others
    
    func checkBitNameAvailability() {
        if let _ = PFUser.current()?["bitUsername"] as? String {
            showExploreVC()
        } else {
            showCreateAccountVC()
        }
    }
    
    func showExploreVC() {
        let exploreVCInstance = UINavigationController(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "ExploreVC_ID"))
        exploreVCInstance.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().setFront(exploreVCInstance, animated: true)
        self.revealViewController().setFrontViewPosition(.left, animated: true)
    }
    
    func showCreateAccountVC(_ user: User? = nil) {
        self.hideIndicator()
        let createAccountVCInstance = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountVC_ID") as! CreateAccountVC
        createAccountVCInstance.userToSignup = user
        createAccountVCInstance.navigationSource = AccountEditNavigationSource.signup
        self.navigationController?.pushViewController(createAccountVCInstance, animated: true)
    }
    
    //
}


// MARK: -- Google Plus Delegates

extension ABEulaVC: GIDSignInUIDelegate, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        hideIndicator()
        
        if let err = error {
            print(error)
        } else {
            let userId = "Google:"+GIDSignIn.sharedInstance().currentUser.userID
            func signupDo() {
                //showIndicatorOn(self.googleButtonClick, blockUIFlag: true)
                let usersinup :User = User()
                usersinup.name = GIDSignIn.sharedInstance().currentUser.profile.name
                usersinup.email = GIDSignIn.sharedInstance().currentUser.profile.email
                usersinup.username = userId
                usersinup.googleId = GIDSignIn.sharedInstance().currentUser.userID
                //  usersinup.profilePic = GIDSignIn.sharedInstance().currentUser.profile.imageURLWithDimension(120)
                usersinup.pwd = GIDSignIn.sharedInstance().currentUser.userID
                showIndicator()
                HeyParse.sharedInstance.signUpForNewUser(usersinup) {(isSucceeded, errorInformation) -> Void in
                    self.acceptButton.isEnabled = true
                    self.hideIndicator()
                    if isSucceeded {
                        print("Google signup sucess!!!!!")
                        //self.trackEvent(GAEVSignUp, action: GAEVGoogleSignUp, label: "GoogleSignup", value: nil)
                        self.showCreateAccountVC()
                    } else {
                        var errorMessage = errorInformation ?? ""
                        if errorMessage.range(of: "has already been taken") != nil {
                            errorMessage = "The email address \(GIDSignIn.sharedInstance().currentUser.profile.email) has already been taken."
                        }
                        showAlert("Signup failed!", message: errorMessage, on: self)
                        GIDSignIn.sharedInstance().signOut()
                    }
                }
            }
            
            func signinfo() {
                showIndicator()
                HeyParse.sharedInstance.loginUser(userId, password: GIDSignIn.sharedInstance().currentUser.userID) {(isSucceeded,errorInformation) -> Void in
                    self.acceptButton.isEnabled = true
                    self.hideIndicator()
                    if isSucceeded {
                        self.checkBitNameAvailability()
                        //self.trackEvent(GAEVSignUp, action: GAEVGoogleLogin, label: "GoogleLogin", value: nil)
                    } else {
                        showAlert("Login fail!!", message: errorInformation ?? "", on: self)
                        GIDSignIn.sharedInstance().signOut()
                    }
                }
            }
            
            let query = PFUser.query()
            query!.whereKey("username", equalTo: userId)
            
            query?.getFirstObjectInBackground(block: { (object, error) in
                self.hideIndicator()
                if error != nil { // Error when fetching user with name
                    signupDo()
                } else if object == nil { // No user found when fetching user with name
                    signupDo()
                } else  {  // Fetch user name is success
                    let result = object as! PFUser
                    if (result.username == userId) { // User Found with given name Sign in
                        signinfo()
                    } else { // User name is not matching - Sign Up
                        signupDo()
                    }
                }
            })
            print(GIDSignIn.sharedInstance().currentUser.userID)
        }
    }
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}
