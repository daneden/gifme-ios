//
//  GifmeViewController.swift
//  Gifme
//
//  Created by Daniel Eden on 4/24/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit
import Haneke
import Kingfisher

class GifmeViewController: UICollectionViewController {

    private let reuseID = "gifmeImageCell"
    
    var imageArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cache = Shared.JSONCache
        let URL = NSURL(string: "https://gif.daneden.me/api/v0/all")!
        
        // Make sure we always get a fresh copy of the JSON if we're online
        if(Reachability.connectedToNetwork()) {
            cache.remove(key: "https://gif.daneden.me/api/v0/all")
        }
        
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
        
        let imageURL = NSURL(string: "https://degif.imgix.net/\(self.imageArray[indexPath.row])?fm=jpg&auto=compress&w=248")
        let imageView = UIImageView()
        let placeholderImage = UIImage(named: "placeholder")
        
        imageView.kf_setImageWithURL(imageURL!, placeholderImage: placeholderImage)
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.backgroundView = imageView
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        print(self.imageArray[indexPath.row])
        
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
        
        viewController.imageURL = "https://degif.imgix.net/\(imageName)"
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        viewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(viewController, animated: true, completion: nil)
    }

}
