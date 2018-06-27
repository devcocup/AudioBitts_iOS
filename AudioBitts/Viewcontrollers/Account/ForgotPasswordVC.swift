//
//  ForgotPasswordVC.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 22/12/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit

class ForgotPasswordVC: BaseMainVC {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forgot password"
        configureBackButton()
        configureRightBarButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureBackButton() {
        addBackButton()
    }
    
    override func configureRightBarButton() {
        addRightBarButton("Send")
    }
    
    override func rightBarButtionClicked(_ sender: UIButton) {
        resetPasswordAction()
    }
    
    //Reset the Password
    func resetPasswordAction() {
        HeyParse.sharedInstance.forgotpassword(emailTextField.text! as String) { (isSucceeded, message) -> Void in
            if isSucceeded {
                showAlert("Success", message: message, on: self)
            } else {
                showAlert("Failure", message: message, on: self)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
