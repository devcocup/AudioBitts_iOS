//
//  SigInVC.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 21/12/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import ParseTwitterUtils
import GoogleSignIn
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class User {
    var username: String!
    var name: String!
    var email: String!
    var mobile: String!
    var pwd: String!
    var lastName: String!
    var profilePic: URL?
    var googleId: String?
}

class SignUpVC: BaseMainVC {
    
    /*** To maintain scroll ***/
    @IBOutlet weak var controlsScrollView: UIScrollView!
    @IBOutlet weak var emailControlsHolderView: UIView!
    
    var previousScrollContentSize: CGSize!
    var previousScrollContentOffset: CGPoint!
    //
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookLabel: UILabel!
//    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    // Bottom portion
    @IBOutlet weak var errorInfoLabel: UILabel!
    @IBOutlet weak var haveAccountButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    /*** Terms Of Use & Privacy Policy ***/
    @IBOutlet weak var termsOfUseHolderViewHeightConstraint_Inner: NSLayoutConstraint!
    @IBOutlet weak var termsOfUseHolderViewHeightConstraint_Outer: NSLayoutConstraint!
    
    //
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize sign-in
        var configureError:NSError? = nil
        
        //GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
        switchLoginControls(isSignup: true)
        
        manageTermsOfUseAndPricacyPolicyUI()
        
        // Google Plus
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- NavigationBar button actions
    override func rightBarButtionClicked(_ sender: UIButton) {
        if sender.titleLabel?.text == "Next" {
            signupViaEmail()
        } else if sender.titleLabel?.text == "Login" {
            loginViaEmail()
        }
    }
    
    override func backBtnClicked() {
        // Show signup
        switchLoginControls(isSignup: true, isAnimated: true)
    }
    
    //MARK:- Switch Login controls
    func switchLoginControls(isSignup: Bool, isAnimated: Bool = false) {
        setErrorText(nil)
        
        // Configuring controls
        if isSignup { // Signup
            // Navigation Bar
            self.title = "Create Account"
            addMenuButton()
            addRightBarButton("Next")
            haveAccountButton.isHidden = false
            forgotPasswordButton.isHidden = true
        } else { // Signin
            self.title = "SignIn"
            addLeftBarButton("Cancel")
            addRightBarButton("Login")
            haveAccountButton.isHidden = true
            forgotPasswordButton.isHidden = false
        }
        
        if isAnimated {
            UIView.transition(with: self.view, duration: 1, options: UIViewAnimationOptions.curveEaseOut, animations: { () in }) { (success) in }
            
            // Animation stuff
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = isSignup ? kCATransitionFromLeft : kCATransitionFromRight
            controlsScrollView.layer.add(transition, forKey: nil)
        }
        // Social LoginControls
        changeSocialButtonsText(isSignup: isSignup)
    }
    
    func changeSocialButtonsText(isSignup: Bool) {
        if isSignup {
            facebookLabel.text = "Sign up with Facebook"
//            twitterLabel.text = "Sign up with Twitter"
            googleLabel.text = "Sign up with Google+"
        } else {
            facebookLabel.text = "Sign in with Facebook"
//            twitterLabel.text = "Sign in with Twitter"
            googleLabel.text = "Sign in with Google+"
        }
    }
    
    //MARK:- IBActions
    @IBAction func haveaAnAccountSignIn(_ sender: AnyObject) {
        //trackScreen(GASNLogIn)
        switchLoginControls(isSignup: false, isAnimated: true)
    }
    
    @IBAction func frogotPasswordBtnAction(_ sender: AnyObject) {
        //trackScreen(GASNForgot)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let pusherViewController = sb.instantiateViewController(withIdentifier: "ForgotPasswordVC_ID") as! ForgotPasswordVC
        self.navigationController?.pushViewController(pusherViewController, animated: true)
    }
    
    @IBAction func facebookBtnAction(_ sender: AnyObject) {
        if self.title == "Create Account" {
            showEULAScreen(ABSignUpType.facebook)
        } else if self.title == "SignIn" {
            handleFacebookSignUp()
        }
    }
    
//    @IBAction func twitterBtnAction(_ sender: AnyObject) {
//        if self.title == "Create Account" {
//            showEULAScreen(ABSignUpType.twitter)
//        } else if self.title == "SignIn" {
//            handleTwitterSignUp()
//        }
//    }
    
    @IBAction func googleBtnAction(_ sender: AnyObject) {
        if isInternetAvailable(true) {
            if self.title == "Create Account" {
                showEULAScreen(ABSignUpType.googlePlus)
            } else if self.title == "SignIn" {
                handleGooglePlusSignUp()
            }
        }
    }
    
    func signupViaEmail() {
        if validateUserNameAndPassword() {
            showEULAScreen(ABSignUpType.email)
        }
    }
    
    func showEULAScreen(_ type: ABSignUpType) {
        let eulaInstance = storyboard?.instantiateViewController(withIdentifier: "ABEulaVC_ID") as! ABEulaVC
        eulaInstance.signupType = type
        if type == .email {
            eulaInstance.email = emailTextField.text!
            eulaInstance.userName = emailTextField.text!
            eulaInstance.password = passwordTextField.text!
        }
        navigationController?.pushViewController(eulaInstance, animated: true)
    }
    
    //MARK:- Validations
    func validateUserNameAndPassword() -> Bool {
        if !emailTextField.text!.isEmail() {
            setErrorText("Please enter your correct email address!")
            return false
        } else if passwordTextField.text?.characters.count < 6 {
            setErrorText("Password should have minimum 6 characters!")
            return false
        }
        setErrorText(nil)
        return true
    }
    
    func setErrorText(_ text: String?) {
        if let text = text, text.characters.count != 0 {
            errorInfoLabel.text = text
            errorInfoLabel.isHidden = false
        } else {
            errorInfoLabel.text = "Error Info"
            errorInfoLabel.isHidden = true
        }
    }
    
    func loginViaEmail() {
        if validateUserNameAndPassword() {
            showIndicator()
            self.rightButton.isUserInteractionEnabled = false
            HeyParse.sharedInstance.loginUser(emailTextField.text!, password: passwordTextField.text!) { (isSucceeded,errorInformation) -> Void in
                self.hideIndicator()
                self.rightButton.isUserInteractionEnabled = true
                if isSucceeded {
                    self.checkBitNameAvailability()
                } else {
                    if let errorMessage = errorInformation {
                        self.setErrorText(errorMessage ?? "errror")
                    }
                }
            }
        }
    }
    
    func setOffsetToEmailControls() {
        previousScrollContentSize = controlsScrollView.contentSize
        previousScrollContentOffset = controlsScrollView.contentOffset
        controlsScrollView.contentSize = CGSize(width: controlsScrollView.frame.width, height: controlsScrollView.frame.height * 2)
        controlsScrollView.setContentOffset(CGPoint(x: 0, y: emailControlsHolderView.frame.minY), animated: true)
    }
    
    func reSetOffsetToEmailControls() {
        controlsScrollView.contentSize = previousScrollContentSize
        controlsScrollView.setContentOffset(previousScrollContentOffset, animated: true)
        previousScrollContentSize = nil
        previousScrollContentOffset = nil
    }
    
    
    // MARK: Terms of Use & Privacy Poilcy
    
    func manageTermsOfUseAndPricacyPolicyUI() {
        if !DeviceType.IS_IPHONE_4_OR_LESS && !DeviceType.IS_IPHONE_5 { // For Greater sizes. Ex: iPhone6 and iPhone6 Plus.
            termsOfUseHolderViewHeightConstraint_Inner.constant = 0
            termsOfUseHolderViewHeightConstraint_Outer.constant = 100
        }
        //        else { // For smaller devices. Ex: iPhone5, iPhone4. }
    }
    
    @IBAction func termsOfUseBtnAction(_ sender: UIButton) {
        showPrivacyVC(PrivacyContentType.termsOfUse)
    }
    
    @IBAction func privacyPolicyBtnAction(_ sender: UIButton) {
        showPrivacyVC(PrivacyContentType.privacyPolicy)
    }
    
    func showPrivacyVC(_ contentType: PrivacyContentType) {
        let privacyVCInstance = storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC_ID") as! PrivacyPolicyVC
        privacyVCInstance.contentType = contentType
        self.navigationController?.pushViewController(privacyVCInstance, animated: true)
    }
}

extension SignUpVC { // Navigations
    
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
        hideIndicator()
        let createAccountVCInstance = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountVC_ID") as! CreateAccountVC
        createAccountVCInstance.userToSignup = user
        createAccountVCInstance.navigationSource = AccountEditNavigationSource.signup
        navigationController?.pushViewController(createAccountVCInstance, animated: true)
    }
    
}

//MARK:- Textfield delegates
extension SignUpVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setOffsetToEmailControls()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        reSetOffsetToEmailControls()
        textField.resignFirstResponder()
        return true
    }
}

extension SignUpVC { // All these are temporary methods, Need to optimize it later.
    
    // MARK:- Facebook
    func handleFacebookSignUp() {
        showIndicator(blockUI: true)
        FacebookHelper().doLogin { (loginInfo, errorInformation) -> Void in
            self.hideIndicator()
            if let loginInfo = loginInfo {
                switch loginInfo {
                case .signUp:
                    self.showCreateAccountVC()
                case .login:
                    //self.trackEvent(GAEVLogin, action: GAEVFacebookLogin, label: "FacebookSignup", value: nil)
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
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) { (response: URLResponse?, data: Data?, error: Error?) -> Void in
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
        showIndicator()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    //
    
}

// MARK: -- Google Plus Delegates, This one also temporary

extension SignUpVC: GIDSignInUIDelegate, GIDSignInDelegate {
    
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
                } else {
                    let result = object as! PFUser
                    if (result.username == userId) { // User Found with given name Sign in
                        signinfo()
                    } else { // User name is not matching - Sign Up
                        signupDo()
                    }
                }
//                else if object == nil { // No user found when fetching user with name
//                    signupDo()
//                } else  {  // Fetch user name is success
//
//                }
            })
            print(GIDSignIn.sharedInstance().currentUser.userID)
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
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
