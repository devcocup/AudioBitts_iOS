//
//  CommentVC.swift
//  AudioBitts
//
//  Created by Phani on 12/28/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit
import Parse
import SDWebImage
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




//protocol CommentVCDelegate: class {
//    func reloadFeedAtIndexForComments(index:Int)
//}

class CommentVC: BaseMainVC {
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var bitUserTableView: UITableView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var CommentTextField: UITextField!
    @IBOutlet weak var commentViewConstant: NSLayoutConstraint!
    @IBOutlet weak var bitUserTableHeight: NSLayoutConstraint!
    @IBOutlet weak var bitUserImageView: UIImageView!
    
    var bit : ABFeed?
    var commentsArray = [ABComment]()
    var index = 0
    var bitUser = false
    //    weak var delegate: CommentVCDelegate?
    //    var useraddedComment = false
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Comment"
        configureBackButton()
        fetchComments()
        bitUserTableHeight.constant = 0
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide,object: nil)
        
        sendButton.setBackgroundImage(gradientBackgroundImage(sendButton.frame), for: UIControlState())
        sendButton.setTitleColor(UIColor.abDarkLightGrayColor(), for: UIControlState())
        sendButton.isUserInteractionEnabled = false
        bitUserImageView.image = gradientBackgroundImage(bitUserImageView.frame)
        bitUserTableView.backgroundView = bitUserImageView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureBackButton() {
        addBackButton()
    }
    
    //MARK:- Implemetation of functions
    func fetchComments() {
        if let currentBit = bit {
            HeyParse.sharedInstance.getBitComments(currentBit, completionHandler: { (comments) -> Void in
                self.CommentTextField.text = ""
                self.commentsArray.removeAll()
                self.commentsArray.append(contentsOf: comments)
                self.commentsArray.sort(by: { $0.createdAt!.compare($1.createdAt!) == ComparisonResult.orderedAscending })
                self.commentTableView.reloadData()
            })
        }
    }
    
    func showSignUpVC(){
        let signupVCInstance = UINavigationController(rootViewController: self.storyboard!.instantiateViewController(withIdentifier: "SignUpVC_ID"))
        //signupVCInstance.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().setFront(signupVCInstance, animated: true)
        self.revealViewController().setFrontViewPosition(.left, animated: true)
    }
    
    //MARK: -- Keybord Notications
    func keyboardWillShow(_ notification: Notification) {
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        commentViewConstant.constant = frame.height
    }
    func keyboardWillHide(_ notification: Notification) {
        // let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        commentViewConstant.constant = 0
    }
    
    //MARK:- Show / Hide autocompletion view
    func hideResultsView() {
        commentTableView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.bitUser = false
            self.bitUserTableHeight.constant = 0
            self.view.layoutIfNeeded()
            }) { (isCompleted) -> Void in
        }
    }
    
    func showResultsView() {
        commentTableView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.bitUserTableView.bringSubview(toFront: self.commentTableView)
            self.bitUserTableHeight.constant = 150
            self.bitUser = true
            self.view.layoutIfNeeded()
            
            }) { (isCompleted) -> Void in
                self.bitUserTableView .reloadData()
        }
    }
    
    //MARK:Ending ---
    
    //MARK:- IBActions
    @IBAction func sendButtonClick(_ sender: AnyObject) {
        view.endEditing(true)
        if self.CommentTextField.text?.characters.count > 0 {
            if (PFUser.current() != nil) {
                if let bitId = bit?.objectId {
                    sendButton.isUserInteractionEnabled = false
                    showIndicator()
                    HeyParse.sharedInstance.addComment(self.CommentTextField.text!, bitId:bitId) { (success,comment) -> Void in
                        self.hideIndicator()
                        self.sendButton.isUserInteractionEnabled = true
                        self.sendButton.setTitleColor(UIColor.abDarkLightGrayColor(), for: UIControlState())
                        //                    if let delegate = self.delegate {
                        //                        delegate.reloadFeedAtIndexForComments(self.index)
                        //                    }
                        self.CommentTextField.text = nil
                        if success {
                            if (comment != nil) {
                                comment!["commentBy"] = PFUser.current()!
                                self.commentsArray.append(ABComment(pfObject: comment!))
                            }
                            self.commentTableView.reloadData()
                            // sending push for feed user
                            if (PFUser.current()?.objectId != self.bit?.postedBy?.objectId) {
                                HeyParse.sharedInstance.commentPush(self.bit!)
                                HeyParse.sharedInstance.tagedpush(self.bit?.bitTitle ?? "", message: self.CommentTextField.text!)
                            }
                            if self.commentsArray.count > 2 {
                                self.commentTableView.scrollToRow(at: IndexPath(row: self.commentsArray.count-1, section: 0), at: .bottom, animated: true)
                            }
                        } else {
                            showAlert("Error !!", message: "", on: self)
                        }
                    }
                }
            } else {
                showAlert("Hi Guest!!", message: "Please login to comment", on: self)
            }
        }
    }
}

// MARK:- Tableview datasource
extension CommentVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bitUser {
            return SharedManager.sharedInstance.allBitUserNames.count
        } else {
            return commentsArray.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bitUser {
            let bitcell = tableView.dequeueReusableCell(withIdentifier: "BitUserCellIdentifier", for: indexPath) as! BitUserTVCell
            bitcell.bitUserLabel.text = SharedManager.sharedInstance.allBitUserNames[indexPath.row].replacingOccurrences(of: "@", with: "")
            return bitcell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTVCellIdentifier", for: indexPath) as! CommentTVCell
            cell.commentLabel.text = commentsArray[indexPath.row].comment ?? ""
            cell.timeLabel.text = commentsArray[indexPath.row].createdAt?.timeAgoSimple
            cell.profileImageView.sd_setImage(with: URL(string:commentsArray[indexPath.row].postedBy?.profilePic?.url ?? "" ), placeholderImage: UIImage(named: "profile_placeholder"))
            cell.nameLabel.text = commentsArray[indexPath.row].postedBy?.bitUserName?.chopPrefix()
            cell.bottomLineView.isHidden = false
            if (commentsArray.count == indexPath.row ) {
                cell.bottomLineView.isHidden = true
            }
            return cell
        }
    }
}

// MARK:- Tableview delegates
extension CommentVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if bitUser {
            hideResultsView()
            CommentTextField.text = (CommentTextField.text)! + SharedManager.sharedInstance.allBitUserNames[indexPath.row]
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if bitUser {
            return 20
        } else {
            let item = commentsArray[indexPath.row].comment ?? ""
            let widthOfLabel = Double(view.frame.size.width) - 45
            let textHeight = item.sizeOfString(UIFont.museoSanRegularFontOfSize(14), constrainedToWidth: widthOfLabel)
            return (45 + textHeight.height)
        }
    }
}

// MARK:- Textfield delegates
extension CommentVC : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (PFUser.current() != nil) {
            sendButton.setTitleColor(UIColor.white, for: UIControlState())
            sendButton.isUserInteractionEnabled = true
            self.view.needsUpdateConstraints()
            return true
        } else {
            showSignUpVC()
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.needsUpdateConstraints()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideResultsView()
        textField.resignFirstResponder()
        self.view.needsUpdateConstraints()
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "@" {
            showResultsView()
            return false
        } else {
            hideResultsView()
        }
        return true
    }
}
