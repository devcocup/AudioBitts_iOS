//
//  GlobalFunctions.swift
//  Voler
//
//  Created by Manoj on 14/09/15.
//  Copyright © 2015 MobileWays. All rights reserved.
//

import Foundation
import Parse

func getAttributedDateString(_ text: String) ->  NSAttributedString {
    
    func colorForIndex(_ index: Int) -> UIColor {
        var color = UIColor.red
        if index == 1{ color = UIColor.red}
        return color
    }
    
    let strings = text.components(separatedBy: ",")
    let attributedString = NSMutableAttributedString()
    for (index, string) in strings.enumerated() {
        attributedString.append(NSAttributedString(string:  String(string),
            attributes: [NSForegroundColorAttributeName: colorForIndex(index), NSFontAttributeName: UIFont.museoSanRegularFontOfSize(13)]))
        if index == 0 || index == 1 {
            attributedString.append(NSAttributedString(string:  ",",
                attributes: [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont.museoSanRegularFontOfSize(13)]))
        }
    }
    return attributedString
}

func constrainViewEqual(_ holderView: UIView, view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    //pin 100 points from the top of the super
    let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
        toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
    let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
        toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
    let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
        toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
    let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
        toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)
    holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
}

//top:CGFloat, left:CGFloat, right:CGFloat, bottom:CGFloat
func constrainViewEqualAndOffset(_ holderView: UIView, view: UIView, constraints:(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)) {
    view.translatesAutoresizingMaskIntoConstraints = false
    //pin 100 points from the top of the super
    let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
        toItem: holderView, attribute: .top, multiplier: 1.0, constant: constraints.top)
    let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
        toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: constraints.bottom)
    let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
        toItem: holderView, attribute: .left, multiplier: 1.0, constant: constraints.left)
    let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
        toItem: holderView, attribute: .right, multiplier: 1.0, constant: constraints.right)
    
    holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    
}

func showAlertOnWindow(title: String? = nil, message: String? = nil) {
    if title == nil && message == nil {
        print("Requried 'title' or 'message' to show alert.")
        return
    }
    
    let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    getTopViewController()?.present(alert, animated: true, completion: nil)
    
}

func showAlert(_ title: String, message: String, on: AnyObject?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    on?.present(alert, animated: true, completion: nil)
}

func classNameAsString(_ obj: Any) -> String {
    //prints more readable results for dictionaries, arrays, Int, etc
//    return _stdlib_getDemangledTypeName(obj).componentsSeparatedByString(".").last!
    return String(describing: type(of: (obj) as AnyObject))
}

func removeAMPM(_ dateString: String?) -> String {
    if var result =  dateString {
        result = result.replacingOccurrences(of: "AM", with: "")
        result = result.replacingOccurrences(of: "PM", with: "")
        return result
    }
    return ""
}

func gradientBackgroundImage(_ updatedFrame: CGRect) -> UIImage {
    let layer = CAGradientLayer.gradientLayerForBounds(updatedFrame)
    UIGraphicsBeginImageContext(layer.bounds.size)
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

func isFirstLaunch() -> Bool {
    let defaults = UserDefaults.standard
    if defaults.bool(forKey: "FirstLaunch") {
        return false
    } else {
        return true
    }
}

func disableFirstLaunch() {
    let defaults = UserDefaults.standard
    defaults.set(true, forKey: "FirstLaunch")
}

func removeWhitespace(_ string: String) -> String {
    let components = string.components(separatedBy: CharacterSet.whitespaces)
    let filtered = components.filter({!$0.isEmpty})
    return filtered.joined(separator: " ")
}

func getInt(_ input: String?) -> Int {
    if let input = input  {
        if let doubleValue = Double(input) {
            return Int(doubleValue)
        }
        return 0
    }
    return 0
}

func getDouble(_ input: String?) -> Double {
    if let input = input  {
        let cleanVlaue =  input.replacingOccurrences(of: "%", with: "")
        if let doubleValue = Double(cleanVlaue) {
            return doubleValue
        }
        return 0
    }
    return 0
}

func validateEmail(_ user: PFUser) -> Bool {
    if let email = PFUser.current()?.email {
        let emailString = removeWhitespace(email)
        return emailString.isEmpty ? false : true
    }
    return false
}

func validateMobile(_ user: PFUser) -> Bool {
    if let mobile = PFUser.current()?["mobile"] {
        let mobileString = removeWhitespace(mobile as! String)
        return mobileString.isEmpty ? false : true
    }
    return false
}

func compressImage(_ image:UIImage) -> Data {
    // Reducing file size to a 10th
    
    var actualHeight : CGFloat = image.size.height
    var actualWidth : CGFloat = image.size.width
    let maxHeight : CGFloat = 400.0
    let maxWidth : CGFloat = 640.0
    var imgRatio : CGFloat = actualWidth/actualHeight
    let maxRatio : CGFloat = maxWidth/maxHeight
    var compressionQuality : CGFloat = 1.0 // compressee
    
    if (actualHeight > maxHeight || actualWidth > maxWidth) {
        if(imgRatio < maxRatio) {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio) {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        } else {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
            compressionQuality = 1;
        }
    }
    
    let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    image.draw(in: rect)
    let img = UIGraphicsGetImageFromCurrentImageContext();
    let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
    UIGraphicsEndImageContext();
    return imageData!;
}

func setProfilePic(on imageView: UIImageView, user: ABUser?, fromSideMenu: Bool) {
    if let profilePic = user?.profilePic {
        profilePic.getDataInBackground(block: { (data, error) -> Void in
            if let imageData = data {
                imageView.image = UIImage(data: imageData)
            } else {
                setTextOnImageView(imageView: imageView, user: user, fromSideMenu: fromSideMenu)
            }
        })
    } else {
        setTextOnImageView(imageView: imageView, user: user, fromSideMenu: fromSideMenu)
    }
}

func setTextOnImageView(imageView: UIImageView, user: ABUser?, fromSideMenu: Bool) {
    if let user = user {
        if let name = user.fullName, name.characters.count > 0 {
            if fromSideMenu {
                imageView.setImageWith(name, color: UIColor.abDarkLightGrayColor())
            } else {
                imageView.setImageWith(name, color: UIColor.imageBackgroundColor())
            }
        } else if let userName = user.bitUserName, userName.characters.count > 3 {
            if fromSideMenu {
                imageView.setImageWith("\(userName[1]) \(userName[2])", color: UIColor.abDarkLightGrayColor())
            } else {
                imageView.setImageWith("\(userName[1]) \(userName[2])", color: UIColor.imageBackgroundColor())
            }
        }
    }
}

func handleNavigationAbility(_ cell: FeedsTVCell, feed: ABFeed) {
    if feed.bittInteractionFlag {
        // Comment
        cell.commentImgView.alpha = 1
        cell.commentButton.isUserInteractionEnabled = true
        
        // Like
        cell.likeImageView.alpha = 1
        cell.likeButton.isUserInteractionEnabled = true
        
        // Share
        cell.shareImgView.alpha = 1
        cell.shareButton.isUserInteractionEnabled = true
    } else {
        // Comment
        cell.commentImgView.alpha = 0.3
        cell.commentButton.isUserInteractionEnabled = false
        
        // Like
        cell.likeImageView.alpha = 0.3
        cell.likeButton.isUserInteractionEnabled = false
        
        // Share
        cell.shareImgView.alpha = 0.3
        cell.shareButton.isUserInteractionEnabled = false
    }
    

    
    if feed.userInteractionFlag {
        // Profile
        cell.profileImageView.alpha = 1
        cell.nameLabel.alpha = 1
        cell.tittlelabel.alpha = 1
//        cell.profileHeaderView.alpha = 1
        cell.profileHeaderView.isUserInteractionEnabled = true
    } else {
        // Profile
        cell.profileImageView.alpha = 0.3
        cell.nameLabel.alpha = 0.3
        cell.tittlelabel.alpha = 0.3
//        cell.profileHeaderView.alpha = 0.3
        cell.profileHeaderView.isUserInteractionEnabled = false
    }
}

