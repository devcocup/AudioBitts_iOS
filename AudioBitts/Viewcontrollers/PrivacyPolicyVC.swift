//
//  PrivacyPolicyVC.swift
//  AudioBitts
//
//  Created by Phani on 2/1/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit

enum PrivacyContentType {
    case privacyPolicy, termsOfUse
}

class PrivacyPolicyVC: BaseMainVC {
    
    @IBOutlet weak var contentTypeTitleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    var contentType = PrivacyContentType.privacyPolicy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fillUpTheData()
    }
    
    override func configureBackButton() {
        addBackButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:-
    func fillUpTheData() {
        switch contentType {
        case .termsOfUse:
            title = "Terms and Conditions"
            contentTypeTitleLabel.text = title
            self.contentTextView.text = SharedManager.sharedInstance.termsAndConditions
            //trackScreen(GASNTermsAndConditions)
        case .privacyPolicy:
            title = "Privacy Policy"
            let path = Bundle.main.path(forResource: "AudioBitts_Privacy", ofType: "txt")!
            do {
                self.contentTextView.text = try String(contentsOfFile: path)
            } catch { print("Error in contentsOfFile") }
            //trackScreen(GASNPrivacyPolicy)
        }
        
        contentTypeTitleLabel.text = title
        perform(#selector(PrivacyPolicyVC.adjustTextViewContextOffset), with: nil, afterDelay: 0)
    }
    
    func adjustTextViewContextOffset() {
        contentTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
}

extension PrivacyPolicyVC:UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}
