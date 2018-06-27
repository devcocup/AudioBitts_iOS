//
//  UIViewController+Extension.swift
//  CamPlusAudio
//
//  Created by Ashok on 13/12/15.
//  Copyright © 2015 Ashok. All rights reserved.
//

import UIKit

extension UIViewController {
    func configureChildViewController(_ childController: UIViewController, onView: UIView?) {
        var holderView = self.view
        if let onView = onView {
            holderView = onView
        }
        addChildViewController(childController)
        holderView?.addSubview(childController.view)
        constrainViewEqual(holderView!, view: childController.view)
        childController.didMove(toParentViewController: self)
    }
    
    func scatterChildViewController(_ childController: UIViewController) {
        childController.willMove(toParentViewController: self)
        childController.view.removeFromSuperview()
        childController.removeFromParentViewController()
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

}
