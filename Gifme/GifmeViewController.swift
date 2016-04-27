//
//  GifmeViewController.swift
//  Gifme
//
//  Created by Daniel Eden on 4/24/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit
import Haneke

class GifmeViewController: UICollectionViewController {

    private let reuseID = "gifmeImageCell"
    
    var imageArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cache = Shared.JSONCache
        let URL = NSURL(string: "https://gif.daneden.me/api/v0/all")!
        
        cache.fetch(URL: URL).onSuccess { JSON in
            let imageNames: [String] = (JSON.dictionary?["images"])! as! [String]
            
            self.imageArray = []
            for image in imageNames {
                let imageURL = "\(image)"
                self.imageArray.append(imageURL)
            }
            
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.redColor()
        
        let imageURL = NSURL(string: "https://degif.imgix.net/\(self.imageArray[indexPath.row])?f=jpg&q=40&w=250")
        let imageView = UIImageView()
        let placeholderImage = UIImage(named: "placeholder-image")
        
        imageView.hnk_setImageFromURL(imageURL!, placeholder: placeholderImage, format: Format<UIImage>(name: "124x124") {
            let resizer = ImageResizer(size: CGSizeMake(124,124),
                scaleMode: imageView.hnk_scaleMode
            )
            
            return resizer.resizeImage($0)
        })
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.backgroundView = imageView
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (self.view.frame.width / 3) - 1
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageName = self.imageArray[indexPath.row]
        let viewController = GifmeImageViewController()
        var image:UIImage
        
        if imageName.hasSuffix(".gif") {
            image = UIImage.gifWithURL("https://degif.imgix.net/\(imageName)")!
            viewController.imageView.image = image
        } else {
            let imageURL = NSURL(string: "https://degif.imgix.net/\(imageName)")
            viewController.imageView.hnk_setImageFromURL(imageURL!)
        }
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }

}
