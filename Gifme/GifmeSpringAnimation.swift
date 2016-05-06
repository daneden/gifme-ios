//
//  GifmeSpringAnimation.swift
//  Gifme
//
//  Created by Daniel Eden on 5/6/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import Foundation
import pop

func makeAnimation(property: String, from: AnyObject, to: AnyObject) -> POPSpringAnimation {
    let anim = POPSpringAnimation(propertyNamed: property)
    
    anim.fromValue = from
    anim.toValue = to
    
    anim.springSpeed = 10
    anim.springBounciness = 6
    
    return anim
}