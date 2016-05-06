//
//  GifmeCollectionViewCell.swift
//  Gifme
//
//  Created by Daniel Eden on 4/27/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit
import pop

class GifmeCollectionViewCell: UICollectionViewCell {
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                UIView.animateWithDuration(0.2, animations: {
                    self.alpha = 0.5
                })
            } else {
                UIView.animateWithDuration(0.2, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}
