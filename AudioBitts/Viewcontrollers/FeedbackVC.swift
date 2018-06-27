//
//  FeedbackVC.swift
//  AudioBitts
//
//  Created by Manoj Kumar on 01/02/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import MessageUI
import Parse

class FeedbackVC: BaseMainVC {
    
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var isReportAbuse: Bool!
    var feedBackmail = SharedManager.sharedInstance.feedbackEmail
    
    var feedbackType: ABFeedbackType!
    var userFlagged: ABUser?
    var feedFlagged: ABFeed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureBackButton()
        configureRightBarButton()
        self.title = "Feedback"
        
        if (isReportAbuse == true) {
            tittleLabel.text = "SOMETHING ISN’T WORKING"
            descriptionLabel.text = "Briefly explain what went wrong, and we will do our best to fix it."
        }
        
        
        switch feedbackType! {
        case .GeneralFeedback:
            tittleLabel.text = "GENERAL FEEDBACK"
            descriptionLabel.text = "Tell us how we can improve, or just show us some love."
        case .SomethingIsntWorking:
            tittleLabel.text = "SOMETHING ISN’T WORKING"
            descriptionLabel.text = "Briefly explain what went wrong, and we will do our best to fix it."
        case .ReportAbuse:
            tittleLabel.text = "REPORTING ABUSE"
            descriptionLabel.text = "Briefly explain the reason for your complaint."
        }
    }
    
    override func configureRightBarButton() {
        addRightBarButton("Send")
    }
    
    override func configureBackButton() {
        addBackButton()
    }
    
    override func rightBarButtionClicked(_ sender: UIButton) {
        feedbackTextView.resignFirstResponder()
        print("Send button Action")
        sendEmail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendEmail() {
        if(MFMailComposeViewController.canSendMail()) {
            print("Can send email.")
            
            let body = "\(self.feedbackTextView.text ?? "")\((feedFlagged != nil) ? "\n\nFeed id: \((feedFlagged!.objectId)!)" : "")\((PFUser.current() != nil) ? "\n\nReported by: \((PFUser.current()!["bitUsername"])!)" : "")"
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([feedBackmail])
            
            //Set the subject and message of the email
            mailComposer.setSubject("\(tittleLabel.text!): \(descriptionLabel.text!)")
            mailComposer.setMessageBody(body, isHTML: false)
            
            //            if let filePath = NSBundle.mainBundle().pathForResource("swifts", ofType: "wav") {
            //                print("File path loaded.")
            //
            //                if let fileData = NSData(contentsOfFile: filePath) {
            //                    print("File data loaded.")
            //                    mailComposer.addAttachmentData(fileData, mimeType: "audio/wav", fileName: "swifts")
            //                }
            //            }
            self.present(mailComposer, animated: true, completion: nil)
        } else {
            showAlert("Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", on: self)
        }
    }
}

extension FeedbackVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
        
        if result == MFMailComposeResult.sent {
            ABFeedbackHandler().saveUserFeedback(feedbackTextView.text, type: feedbackType, feedFlagged: feedFlagged, userFlagged: userFlagged)
        }
        
        self.navigationController?.popToRootViewController(animated: false)
    }
}
