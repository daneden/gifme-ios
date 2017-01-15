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
    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}
