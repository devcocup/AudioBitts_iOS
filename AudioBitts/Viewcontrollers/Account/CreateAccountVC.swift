//
//  CreateAccountVC.swift
//  AudioBitts
//
//  Created by Phani on 12/22/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import UIImageView_Letters
import Parse
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


enum AccountEditNavigationSource {
    case home
    case signup
    case profile
}

class CreateAccountVC: BaseMainVC, UINavigationControllerDelegate {
    
    @IBOutlet weak var bitUsernameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var isPrivateSwitch: UISwitch!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailIdTextField: UITextField!
    
    //---> To deal with hiding some tabs
    @IBOutlet weak var fieldsHolderView: UIView!
    @IBOutlet weak var publicViewHeightConstraint: NSLayoutConstraint!
    //
    
    var user: ABUser?
    let imagePicker = UIImagePickerController()
    var image :UIImage?
    
    var userToSignup: User?
    var navigationSource = AccountEditNavigationSource.signup
    var isProfilePicChanged = false
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (user != nil) {
            showUserProfileDetails()
        } else {
            self.title = "Create Account"
            print("No user Data")
        }
        configureRightBarButton()
        configureBackButton()
        cameraButton.layer.borderColor = UIColor.abGrayColor().cgColor
        self.cameraButton.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.imagePicker.delegate = self
        
        if navigationSource != .profile { // Need to hide some tabs
            publicViewHeightConstraint.constant = 0
            for i in 104 ..< 107 {
                let fieldView = fieldsHolderView.viewWithTag(i)!
                fieldView.isHidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UI configuration
    override func configureBackButton() {
        switch navigationSource {
        case .signup:
            addLeftBarButton("Back")
        case .profile:
            addBackButton()
        case .home:
            print("Username is mandatory!!!")
        }
    }
    
    override func backBtnClicked() {
        super.backBtnClicked()
        if navigationSource == .signup {
            ABUserManager.sharedInstance.logOut()
        }
    }
    
    override func configureRightBarButton() {
        addRightBarButton("Done")
    }
    
    // MARK:- Implementation of functions
    func showUserProfileDetails() {
        self.title = "Edit Profile"
        let name =  user?.bitUserName  ?? "Welcome"
        fullNameTextField.text = user?.fullName ?? ""
        bitUsernameTextField.isUserInteractionEnabled = false
        bitUsernameTextField.text = String(name.characters.dropFirst())
        if user!.isPrivate == true {
            isPrivateSwitch.setOn(true, animated: false)
        } else {
            isPrivateSwitch.setOn(false, animated: false)
        }
        emailIdTextField.text = user?.email ?? ""
        ageTextField.text = user?.age ?? ""
        genderTextField.text = user?.gender ?? ""
        if let profilePic = user?.profilePic {
            profilePic.getDataInBackground(block: { (data, error) -> Void in
                if let imageData = data {
                    self.image = UIImage(data: imageData)
                    self.cameraButton.setImage(self.image, for: UIControlState())
                }
            })
        }
    }
    
    func showExploreVC() {
        let exploreVCInstance = UINavigationController(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "ExploreVC_ID"))
        //exploreVCInstance.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().setFront(exploreVCInstance, animated: true)
        self.revealViewController().setFrontViewPosition(.left, animated: true)
    }
    
    func saveDetails() {
        if userToSignup != nil {
            showIndicator()
            HeyParse.sharedInstance.signUpForNewUser(userToSignup!) {(isSucceeded, errorInformation) -> Void in
                self.hideIndicator()
                if isSucceeded {
                    self.saveExistingUserInfo()
                } else {
                    showAlert("Signup failed!", message: errorInformation!.capitaliseFirstLetterInSentence()  ?? "", on: self)
                }
            }
        } else {
            saveExistingUserInfo()
        }
    }
    
    func saveExistingUserInfo() {
        let user = PFUser.current()!
        if let imageupload = image {
            user["profilePic"] = PFFile(name:"piccture", data:compressImage(imageupload))
        }
        
        user["bitUsername"] = "@\(bitUsernameTextField.text!)"
        if ageTextField.text?.characters.count > 1 {
            user["age"] = "\(ageTextField.text!)"
        }
        
        user["gender"] = genderTextField.text!
        user["fullName"] = fullNameTextField.text!
        
        if let email = emailIdTextField.text, !email.isEmpty {
            user["email"] = emailIdTextField.text!
        }
        
        if isPrivateSwitch.isOn {
            user["isPrivate"] = true
        } else {
            user["isPrivate"] = false
        }
        
        // for Push Notifications Registration
        if let userdata =  PFUser.current() {
            let currentInstallation = PFInstallation.current()
            currentInstallation?["user"] = userdata
            currentInstallation?["bitUsername"] = userdata["bitUsername"] ?? ""
            currentInstallation?.saveInBackground()
        }
        rightButton.isUserInteractionEnabled = false
        user.saveInBackground (block: { (sucess, error) -> Void in
            self.rightButton.isUserInteractionEnabled = true
            if sucess {
                self.showExploreVC()
            } else {
                var errorMessage = error?.localizedDescription ?? ""
                if errorMessage.range(of: "has already been taken") != nil {
                    errorMessage = "The email address \(self.emailIdTextField.text) has already been taken."
                }
                showAlert("Error!", message: errorMessage, on: self)
            }
        })
    }
    
    // MARK:- IBActions
    @IBAction func cameraButtonClick(_ sender: AnyObject) {
        showActionSheet()
    }
    
    override func rightBarButtionClicked(_ sender: UIButton) {
        view.endEditing(true)
        if isDataValid() {
            if ageEntered() {
                if getInt(self.ageTextField.text) >= 13 && getInt(self.ageTextField.text) <= 110 {
                    checkBitname()
                } else {
                    showAlert("Age invalid!!", message: "Age Must be 13 years and over", on: self)
                    self.ageTextField.text = ""
                }
            } else {
                checkBitname()
            }
        }
    }
    
    @IBAction func showGenderPicker(_ sender: AnyObject) {
        view.endEditing(true)
        ActionSheetStringPicker.show(withTitle: "Gender", rows: ["Male", "Female"], initialSelection: 0, doneBlock: {
            picker, value, index in
            self.genderTextField.text = ("\(index)")
            return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
    //MARK:- Validations
    func isDataValid() -> Bool {
        if let email = emailIdTextField.text, !email.isEmpty {
            if email.isEmail() {
                return true
            } else {
                showAlert("", message: "Invalid email address.", on: self)
                return false
            }
        }
        return true
    }
    
    func checkBitname() {
        if navigationSource != .profile { // in editing don't check user name exits or not
            if bitUsernameTextField.text?.characters.count >= 6 {
                rightButton.isUserInteractionEnabled = false
                HeyParse.sharedInstance.findDuplicates("bitUsername", value: "@\(bitUsernameTextField.text!)", completionHandler: { (isFound,existedUserType) -> Void in
                    if !isFound {
                        self.saveDetails()
                    } else {
                        self.rightButton.isUserInteractionEnabled = true
                        showAlert("\(self.bitUsernameTextField.text!) username already exits", message: "Please use another name", on: self)
                    }
                })
            } else {
                showAlert("Invalid Username!", message: "Username should have minimum of 6 characters.", on: self)
            }
        } else {
            self.saveDetails()
        }
    }
    
    func ageEntered() -> Bool {
        if ageTextField.text?.characters.count > 1 {
            return true
        } else {
            return false
        }
    }
}

// MARK: - Image Picker Delegates
extension  CreateAccountVC : UIImagePickerControllerDelegate {
    
    // MARK : - Show action sheet
    fileprivate func showActionSheet() {
//        self.cameraButton.imageView.
        cameraButton.layer.borderColor = UIColor.navBarStartColor().cgColor
        cameraButton.layer.borderWidth = 2.0
        let vc = VKActionController()
        vc.addAction(VKAction(title: "Photo Library", image: UIImage(named: "photo_library"), color: UIColor.white, cancelTitle: "") { (action) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .popover
            self.present(self.imagePicker, animated: true, completion: nil)
            
            })
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
            vc.addAction(VKAction(title: "Take selfie", image: UIImage(named: "take_selfi"), color: UIColor.white, cancelTitle: "") { (action) -> Void in
                self.imagePicker.sourceType = .camera
                self.imagePicker.modalPresentationStyle = .popover
                self.present(self.imagePicker, animated: true, completion: nil)
                })
        } else {
            print("No Camera Found")
        }
        
        vc.addAction(VKAction(title: "", image: nil, color: UIColor.abGrayColor(), cancelTitle: "Cancel") { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
            if self.isProfilePicChanged {
                self.cameraButton.layer.borderColor = UIColor.navBarEndColor().cgColor
            } else {
                self.cameraButton.layer.borderColor = UIColor.white.cgColor
            }
            })
        present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        image = chosenImage
        isProfilePicChanged = true
        cameraButton.setImage(chosenImage, for: UIControlState())
        cameraButton.layer.borderColor = UIColor.navBarStartColor().cgColor
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        cameraButton.layer.borderColor = UIColor.white.cgColor
    }
}

// MARK:- Textfield delegates
extension CreateAccountVC : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == bitUsernameTextField {
            let set = CharacterSet(charactersIn: "ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_").inverted
            return string.rangeOfCharacter(from: set) == nil
        } else if textField == ageTextField {
            let set = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: set) == nil
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == bitUsernameTextField {
            if (bitUsernameTextField.text != nil) {
                HeyParse.sharedInstance.findDuplicates("bitUsername", value: "@\(bitUsernameTextField.text!)", completionHandler: { (isFound,existedUserType) -> Void in
                    if isFound {
                        showAlert("\(self.bitUsernameTextField.text) username already exits", message: "Please use another name", on: self)
                        self.bitUsernameTextField.text = nil
                    }
                })
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
}
