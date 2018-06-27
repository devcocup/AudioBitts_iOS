//
//  UISearchBarExtension.swift
//  ReusableComponents_Ashok
//
//  Created by Ashok on 22/03/16.
//  Copyright © 2016 Ashok. All rights reserved.
//

import UIKit

public extension UISearchBar {
    
    public func setTextColor(_ color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
}
