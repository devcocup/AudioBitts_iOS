//
//  ShareVC.swift
//  AudioBitts
//
//  Created by Navya on 27/01/16.
//  Copyright © 2016 mobileways. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import ActiveLabel
import Parse


class ShareVC: BaseMainVC, UITextViewDelegate {
    
    
    @IBOutlet weak var bitUserTableHeight: NSLayoutConstraint!
    @IBOutlet var titleTextView: KMPlaceholderTextView!
    @IBOutlet var charactersLeft: UILabel!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet weak var commentLabel: ActiveLabel!
    @IBOutlet weak var enterView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var bitUserTableView: UITableView!
    @IBOutlet weak var bitUserImageView: UIImageView!
    @IBOutlet weak var enterViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionView: UIView!
    
    var counter = 0
    var timer :Timer!
    var charCount: Int!
    let maxLength = 40
    var updatedText: String?
    var updatedCommentText: String?
    var keyboardToolbar: UIToolbar?
    var selectedImage: UIImage?
    var myString = ""
    var countValue: String!
    var isEdit : Bool!
    let dataModel = ExploreVC()
    var indexpath: IndexPath!
    var feed: ABFeed!
    var feedsTV: UITableView!
    var feedsArray: [ABFeed] = []
    var complettionHandler:((_ title: KMPlaceholderTextView, _ desc: UILabel) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel.delegate = self as ExploreVCDelegate
        titleTextView.delegate = self
        titleTextView.becomeFirstResponder()
        commentTextField.delegate = self
        configureBackButton()
        
        bitUserTableView.isHidden = true
        enterView.isHidden = true
        
        bitUserImageView.image = gradientBackgroundImage(bitUserImageView.frame)
        bitUserTableView.backgroundView = bitUserImageView
        
        //Done button
        //    keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        //    keyboardToolbar!.barStyle = .BlackTranslucent
        //    keyboardToolbar!.items = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .Done, target: self, action: "resignTextViewKeyboard")]
        //    keyboardToolbar?.tintColor = UIColor.navBarStartColor()
        //    keyboardToolbar!.sizeToFit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShareVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShareVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide,object: nil)
        
        commentLabel.handleMentionTap { userHandle in print("\(userHandle) tapped") }
        commentLabel.handleHashtagTap { hashtag in print("\(hashtag) tapped") }
        commentLabel.handleURLTap { url in print("\(url) tapped") }
    
        
        shareButton.isUserInteractionEnabled = false
        
        //Tapgesture to label
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShareVC.labelTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        commentLabel.addGestureRecognizer(tapGestureRecognizer)
        commentLabel.isUserInteractionEnabled = true
        
        //Keyboard customization
        commentTextField.returnKeyType = UIReturnKeyType.done
        commentTextField.keyboardType = UIKeyboardType.emailAddress
        commentTextField.autocorrectionType = UITextAutocorrectionType.no
        titleTextView.returnKeyType = UIReturnKeyType.done
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureBackButton() {
        addLeftBarButton("Back")
    }
    
    override func backBtnClicked() {
        self.dismiss(animated: false, completion: nil)
        if isEdit == true {
            navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Keybord Notications
    func keyboardWillShow(_ notification: Notification) {
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        enterViewConstraint.constant = frame.height
    }
    
    func keyboardWillHide(_ notification: Notification) {
        enterViewConstraint.constant = 0
    }
    
    //MARK:- Implementation of functions
    func labelTapped() {
        enterView.isHidden = false
        commentTextField.text = commentLabel.text
        
        if commentLabel.text == "add Bitt tags and tag users here" {
            commentLabel.text = ""
            commentTextField.text = ""
        }
        commentTextField.becomeFirstResponder()
    }
    
    func shareBtnEnable() {
        if titleTextView.text != nil && commentLabel.text != nil {
            shareButton.setBackgroundImage(gradientBackgroundImage(shareButton.frame), for: UIControlState())
            shareButton.isUserInteractionEnabled = true
        }
    }
    
    func saveTheInfo() {
        showIndicator(blockUI: true)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ShareVC.timerAction), userInfo: nil, repeats: true)
        HeyParse.sharedInstance.saveFeed(titleTextView.text!, tags: commentLabel.text!, image: selectedImage!,audioDuartionTimer: countValue) { (errorInformation) -> Void in
            self.hideIndicator()
            if let errorInformation = errorInformation {
                self.handleError(errorInformation)
            } else {
                self.timer.invalidate()
                print("time->\(self.counter)")
                //                self.handleSuccess()
                self.dismissSelf(true)
            }
        }
    }
    
    func timerAction() {
        counter += 1
        print("time->\(counter)")
    }
    
    func handleSuccess() {
        let alert = UIAlertController(title: "Success!", message: "AudioBit is posted successfully!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.dismissSelf(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleError(_ errorInformation: String) {
        let alert = UIAlertController(title: "Error", message: errorInformation, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.saveTheInfo()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            self.dismissSelf(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func dismissSelf(_ succeeded: Bool) {
        dismiss(animated: false) { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "sharingStatus"), object: self, userInfo: ["succeeded" : succeeded])
        }
    }
    
    func shareBtnDisable() {
        shareButton.setBackgroundImage(UIImage(named: "greybg"), for: UIControlState())
        shareButton.isUserInteractionEnabled = false
    }
    
    func hideResultsView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.bitUserTableHeight.constant = 0
            self.view.layoutIfNeeded()
        }) { (isCompleted) -> Void in
        }
    }
    
    func showResultsView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.enterView.bringSubview(toFront: self.bitUserTableView)
            self.bitUserTableView.bringSubview(toFront: self.bitUserTableView)
            self.bitUserTableView.bringSubview(toFront: self.enterView)
            self.bitUserTableHeight.constant = 150
            self.view.layoutIfNeeded()
            
        }) { (isCompleted) -> Void in
            self.bitUserTableView .reloadData()
        }
    }
    
    // MARK:- IBActions
    @IBAction func doneButtonAction(_ sender: UIButton) {
        commentTextField.resignFirstResponder()
        enterView.isHidden = true
        commentLabel.textColor = UIColor.black
        commentLabel.text = commentTextField.text
        //        if myString?.characters.count == 0 {
        //            commentLabel.text = "add Bitt tags and tag users here"
        //            shareBtnDisable()
        //        }
        if commentLabel.text == "add Bitt tags and tag users here" {
            shareBtnDisable()
            commentLabel.textColor = UIColor.lightGray
            commentLabel.text = ""
        }
        if commentLabel.text == "" {
            commentLabel.text = "add Bitt tags and tag users here"
            shareBtnDisable()
            commentLabel.textColor = UIColor.lightGray
        }
        if titleTextView.text.characters.count > 0 && myString.characters.count > 0 {
            shareBtnEnable()
        }
        if titleTextView.text.characters.count == 0 {
            shareBtnDisable()
        }
        if myString.characters.count == 0 {
            shareBtnDisable()
        }
    }
    
    @IBAction func shareButtonAction(_ sender: AnyObject) {
        if isEdit == true {
            complettionHandler?(titleTextView, commentLabel)
        }
        else {
            saveTheInfo()
        }
        
        
    }
    
    // MARK:- TextView delegate methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        enterView.isHidden = true
        textView.inputAccessoryView = keyboardToolbar
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == titleTextView {
            if text == "" { // Checking backspace
                if textView.text.characters.count == 0 {
                    charCount = 0
                    charactersLeft.text = String(format: "%i", maxLength - charCount)
                    return false
                }
                charCount = (textView.text.characters.count - 1)
                charactersLeft.text = String(format: "%i", maxLength - charCount)
                return true
            } else {
                if text == "\n" {
                    textView.resignFirstResponder()
                    charCount = (textView.text.characters.count )
                    charactersLeft.text = String(format: "%i", maxLength - charCount)
                } else {
                    charCount = (textView.text.characters.count + 1)
                    charactersLeft.text = String(format: "%i", maxLength - charCount)
                }
                
                if charCount >= maxLength + 1 {
                    charCount = maxLength
                    charactersLeft.text = String(format: "%i", maxLength - charCount)
                    return false
                }
            }
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if titleTextView.text.characters.count > 0 && myString.characters.count > 0 {
            shareBtnEnable()
        }
        if titleTextView.text.characters.count == 0 {
            shareBtnDisable()
        }
        if myString.characters.count == 0 {
            shareBtnDisable()
        }
        return true
    }
    
    func resetPlaceHolder(_ textField: UITextField) {
        textField.text = "add Bitt tags and tag users here"
        textField.textColor = UIColor.lightGray
        commentLabel.text = "add Bitt tags and tag users here"
        commentLabel.textColor = UIColor.lightGray
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.beginningOfDocument)
    }
    
}
// MARK:- TableView Datasource
extension ShareVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedManager.sharedInstance.allBitUserNames.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bitcell = tableView.dequeueReusableCell(withIdentifier: "BitUserCellIdentifier", for: indexPath) as! BitUserTVCell
        bitcell.bitUserLabel.text = SharedManager.sharedInstance.allBitUserNames[indexPath.row].replacingOccurrences(of: "@", with: "")
        return bitcell
    }
}

//TableView Delegate
extension ShareVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideResultsView()
        commentTextField.text = (commentTextField.text)! + SharedManager.sharedInstance.allBitUserNames[indexPath.row]
        commentLabel.text = commentTextField.text
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
}

// MARK:- Textfield Delegates
extension ShareVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        commentLabel.text = myString
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if commentLabel.text!.isEmpty {
            resetPlaceHolder(textField)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText:NSString = textField.text! as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:string)
        if updatedText.characters.count == 33 {
            commentLabel.text = string
        } else {
            commentLabel.text = updatedText//(textField.text)! + string
        }
        commentLabel.textColor = UIColor.black
        myString = updatedText
        
        if updatedText.isEmpty {
            resetPlaceHolder(textField)
            return false
        } else if textField.textColor == UIColor.lightGray && !string.isEmpty {
            textField.text = nil
            textField.textColor = UIColor.black
        }
        
        if string == "@" {
            bitUserTableView.isHidden = false
            showResultsView()
            return false
        } else {
            hideResultsView()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextField.resignFirstResponder()
        enterView.isHidden = true
        commentLabel.textColor = UIColor.black
        commentLabel.text = commentTextField.text
        //        if myString?.characters.count == 0 {
        //            commentLabel.text = "add Bitt tags and tag users here"
        //            shareBtnDisable()
        //        }
        if commentLabel.text == "add Bitt tags and tag users here" {
            shareBtnDisable()
            commentLabel.textColor = UIColor.lightGray
            commentLabel.text = ""
        }
        if commentLabel.text == "" {
            commentLabel.text = "add Bitt tags and tag users here"
            shareBtnDisable()
            commentLabel.textColor = UIColor.lightGray
        }
        if titleTextView.text.characters.count > 0 && myString.characters.count > 0 {
            shareBtnEnable()
        }
        if titleTextView.text.characters.count == 0 {
            shareBtnDisable()
        }
        if myString.characters.count == 0 {
            shareBtnDisable()
        }
        return true
    }
}

extension ShareVC: ExploreVCDelegate{
    func searchHashtags() {
        print("in ShareVC")
    }

}
