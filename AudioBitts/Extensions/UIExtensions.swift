//
//  UIExtensions.swift
//  AudioBitts
//
//  Created by Phani on 12/18/15.
//  Copyright © 2015 mobileways. All rights reserved.
//

import Foundation
public typealias Color = UIColor

func RGB(_ r: CGFloat, _ g: CGFloat? = nil, _ b: CGFloat? = nil, _ a: CGFloat = 1) -> UIColor {
    let g = g ?? r, b = b ?? r
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}

extension Color {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1.0)
    }
    
    convenience init(r: Int, g: Int, b: Int, a: Float) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a) )
    }
    
    convenience init(singleColor: Int, a: Float) {
        self.init(red: CGFloat(singleColor)/255, green: CGFloat(singleColor)/255, blue: CGFloat(singleColor)/255, alpha: CGFloat(a) )
    }
    
    class func navBarStartColor() -> Color {
        return Color.init(red: 255 , green: 1, blue: 125)
    }
    class func navBarEndColor() -> Color {
        return Color.init(red: 255, green: 2, blue: 50)
    }
    class func abGrayColor() -> Color {
        return Color.init(red: 242, green: 242, blue: 242)
    }
    class func abSearchSectionBGColor() -> Color {
        return Color.init(red: 216, green: 216, blue: 216)
    }
    class func abDarkLightGrayColor() -> Color {
        return Color.init(red: 187, green: 187, blue: 187)
    }
    class func darkBrownColor() -> Color {
        return Color.init(red: 158, green: 28, blue: 77)
    }
    class func imageBackgroundColor() -> Color {
        return Color.init(red: 14, green: 25, blue: 42)
    }
    class func transparentSearchBarColor() -> Color {
        return Color.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    
}

extension CAGradientLayer {
    class func gradientLayerForBounds(_ bounds: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.startPoint = CGPoint(x: 0.0, y: 1.0)
        layer.endPoint = CGPoint(x: 1.0 , y: 1.0)
        layer.colors = [UIColor.navBarEndColor().cgColor, UIColor.navBarStartColor().cgColor]
        return layer
    }
}
extension UIFont {
    class func museoSanRegularFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Museo Sans", size: size)!
    }
    
    class func museoSans300FontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "MuseoSans-300", size: size)!
    }
    
    class func museoSans500FontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "MuseoSans-500", size: size)!
    }
    
    class func museoSans700FontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "MuseoSans-700", size: size)!
    }
    
    func sizeOfString (_ string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}


