//
//  GifmeButton.swift
//  Gifme
//
//  Created by Daniel Eden on 4/27/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit
import pop

class GifmeButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
                animation.velocity = NSValue(CGPoint: CGPointMake(2, 2))
                animation.springSpeed = 20
                animation.springBounciness = 15
                animation.toValue = NSValue(CGPoint: CGPoint(x: 0.9, y: 0.9))
                self.pop_addAnimation(animation, forKey: "buttonPressedAnimation")
            } else {
                let animation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
                animation.duration = 0.5
                animation.toValue = NSValue(CGPoint: CGPoint(x: 1.0, y: 1.0))
                self.pop_addAnimation(animation, forKey: "buttonReleasedAnimation")
            }
        }
    }

}
