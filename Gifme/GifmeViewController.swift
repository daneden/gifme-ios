//
//  GifmeViewController.swift
//  Gifme
//
//  Created by Daniel Eden on 4/24/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit
import Haneke
import ReachabilitySwift

class GifmeViewController: UICollectionViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {

    private let reuseID = "gifmeImageCell"
    
    var imageArray:[String] = []
    var filteredImages:[String] = []
    
    let searchBar:UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = self.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.barStyle = .black
        searchBar.placeholder = "Search gif.daneden.me"
        searchBar.autocapitalizationType = .none
        searchBar.keyboardAppearance = .dark
        navigationItem.titleView = searchBar
        
        let cache = Shared.JSONCache
        let url = URL(string: "https://gif.daneden.me/api/v0/all")!
        
        // Make sure we always get a fresh copy of the JSON if we're online
        if((Reachability.init()) != nil) {
            cache.remove(key: "https://gif.daneden.me/api/v0/all")
        }
        
        cache.fetch(URL: url).onSuccess { JSON in
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 4
        let spaceBetweenCells: CGFloat = 1
        let dim = (self.view.frame.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath as IndexPath)
    
        let stringURL = self.filteredImages[indexPath.row].addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)
        
        let imageURL = URL(string: "https://degif.imgix.net/\(stringURL!)?fm=jpg&auto=compress&w=248")
        let imageView = UIImageView()
        let placeholderImage = UIImage(named: "placeholder")
        
        imageView.kf.setImage(with: imageURL!, placeholder: placeholderImage)
        imageView.contentMode = .scaleAspectFill
        
        cell.backgroundView = imageView
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.isEmpty == true) {
            self.filteredImages = self.imageArray
        } else {
            self.filteredImages = self.imageArray.filter({( name: String) -> Bool in
                let stringMatch = name.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return (stringMatch != nil)
            })
        }
        
        self.collectionView?.reloadData()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageName = self.filteredImages[indexPath.row]
        let viewController = GifmeImageViewController()
        
        viewController.imageName = imageName
        
        self.searchBar.resignFirstResponder()
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
