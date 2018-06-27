//
//  CustomActivityIndicator.swift
//  Potholes
//
//  Created by Navya on 04/12/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import UIKit

class CustomActivityIndicator: UIView {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var indicatorHolderButton: UIButton?
    var forceToRight = false
    
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear //UIColor.init(red: 14, green: 25, blue: 42) 
        initializeIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeIndicator() {
        self.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = self.superview {
            var xValue: CGFloat = 0
            if superview.isKind(of: UIButton.self) || forceToRight { // Positioning the Indicator wisely in the case of Button
                xValue = ((superview.frame.size.width / 100) * 92) // 92% of the width
                activityIndicator.color = forceToRight ? UIColor(red: 236/255, green: 4/255, blue: 140/255, alpha: 1) : UIColor.white
                indicatorHolderButton = superview as? UIButton
                indicatorHolderButton?.isUserInteractionEnabled = false
            } else { // superview.isKindOfClass(UIView)
                xValue = superview.frame.size.width / 2
                activityIndicator.color = UIColor(red: 236/255, green: 4/255, blue: 140/255, alpha: 1)
            }
            
            let viewWidth: CGFloat = 20
            let viewHeight: CGFloat = 20
            let activityIndicatorSize: CGFloat = 20
            self.frame = CGRect(x: xValue - viewWidth / 2,
                y: superview.frame.height / 2 - viewHeight / 2,
                width: viewWidth,
                height: viewHeight)
            activityIndicator.frame = CGRect(x: viewWidth / 2 - activityIndicatorSize / 2, y: viewHeight / 2 - activityIndicatorSize / 2, width: activityIndicatorSize, height: activityIndicatorSize)
        }
    }
    
    func removeIndicator() {
        self.removeFromSuperview()
        if let indicatorHolderButton = indicatorHolderButton {
            indicatorHolderButton.isUserInteractionEnabled = true
        }
    }
}
