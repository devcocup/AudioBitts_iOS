//
//  PaddingTextField.swift
//  Voler
//
//  Created by Ashok on 08/09/15.
//  Copyright © 2015 MobileWays. All rights reserved.
//

import UIKit
class PaddingTextField: UITextField {
    
    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y,
            width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height);
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }}
