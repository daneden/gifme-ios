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
                self.alpha = 0.5
            } else {
                self.alpha = 1
            }
        }
    }
}

func makeButton(label: String) -> GifmeButton {
    let button = GifmeButton(type: .Custom)
    
    button.setTitle("\(label)", forState: .Normal)
    
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.backgroundColor = UIApplication.sharedApplication().keyWindow?.tintColor
    button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 20, bottom: 10, right: 20)
    
    button.sizeToFit()
    button.translatesAutoresizingMaskIntoConstraints = false
    
    button.layer.cornerRadius = (button.frame.height/2)

    return button
}