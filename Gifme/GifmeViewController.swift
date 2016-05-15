//
//  GifmeViewController.swift
//  Gifme
//
//  Created by Daniel Eden on 4/24/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit
import Haneke

class GifmeViewController: UICollectionViewController, UISearchBarDelegate {

    private let reuseID = "gifmeImageCell"
    
    var imageArray:[String] = []
    var filteredImages:[String] = []
    
    let searchBar:UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = self.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.barStyle = .Black
        searchBar.placeholder = "Search gif.daneden.me"
        searchBar.autocapitalizationType = .None
        searchBar.keyboardAppearance = .Dark
        navigationItem.titleView = searchBar
        
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
            
            // Shuffle the order of gifs so it's different each time
            self.imageArray.shuffleInPlace()
            self.filteredImages = self.imageArray
            
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredImages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath)
    
        let stringURL = self.filteredImages[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())
        
        let imageURL = NSURL(string: "https://degif.imgix.net/\(stringURL!)?fm=jpg&auto=compress&w=248")
        let imageView = UIImageView()
        let placeholderImage = UIImage(named: "placeholder")
        
        imageView.kf_setImageWithURL(imageURL!, placeholderImage: placeholderImage)
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.backgroundView = imageView
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.isEmpty == true) {
            self.filteredImages = self.imageArray
        } else {
            self.filteredImages = self.imageArray.filter({( name: String) -> Bool in
                let stringMatch = name.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return (stringMatch != nil)
            })
        }
        
        self.collectionView?.reloadData()
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (self.view.frame.width / 3) - 1
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageName = self.filteredImages[indexPath.row]
        let viewController = GifmeImageViewController()
        
        viewController.imageName = imageName
        
        self.searchBar.resignFirstResponder()
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
