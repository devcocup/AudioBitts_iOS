//
//  String+Extensions.swift
//  AudioBitts
//
//  Created by Phani on 12/28/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit

extension String {
    func fileContents() -> String? {
        do {
            let content = try String(contentsOfFile: self, encoding: String.Encoding.utf8)
            return content
        } catch _ as Error {
            return nil
        }
    }
    
    func sizeOfString (_ font: UIFont, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size
    }
    func sizeOfStringwithHight (_ font: UIFont, constrainedToHeight height: Double) -> CGSize {
        return NSString(string: self).boundingRect(with: CGSize(width: DBL_MAX, height: height),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size
    }
    func isEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = self.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func isNumberOnly() -> Bool {
        let numberRegEx = "^\\d{10}$"
        let range = self.range(of: numberRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func capitaliseFirstLetterInSentence() -> String {
        return (self as NSString).replacingCharacters(in: NSMakeRange(0, 1), with: (self as NSString).substring(to: 1).uppercased())
    }
    
    
    //    Get nth character of a string
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.substring(to: self.characters.index(self.startIndex, offsetBy: -count))
    }
    
}
