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
    
    var dataLoadingFromAPI: Bool = false
    var remoteData = [Dictionary<String,AnyObject>]()
    // The offset to use when requesting the next batch of tag records from the API.
    var dataNextOffset: String = ""
    
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
        
        self.getDataFromAirtable()
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
    
    func getDataFromAirtable() {
        let tableName = "Tags"
        let limit = "100"
        
        // If we are already loading data...
        if dataLoadingFromAPI {
            return
        }
        
        
        // Set "restaurantsLoading" flag to prevent multiple simultaneous requests.
        dataLoadingFromAPI = true
        
        
        // Prepare the URL request.
        let url = "https://api.airtable.com/v0/\(AIRTABLE_APP_ID)/\(tableName)?limit=\(limit)"
//        if viewName != "" {
//            url = url + "&view=" + viewName.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
//        }
//        if sortField != "" {
//            url = url + "&sortField=" + sortField.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
//            url = url + "&sortDirection=" + sortDirection
//        }
//        if offset != "" {
//            url = url + "&offset=" + offset
//        }
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        
        // Specify the Authorization header.
        urlRequest.addValue("Bearer \(AIRTABLE_API_KEY)", forHTTPHeaderField: "Authorization")
        
        
        // Prepare an NSURLSession to send the data request.
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        
        // Create the data task, along with a completion handler.
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(urlRequest, completionHandler: {(data, response, error) in
            
            // Catch general errors (such as unsupported URLs).
            guard error == nil else {
                print("Error")
                print(error)
                self.dataLoadingFromAPI = false
                return
            }
            
            // Catch HTTP errors (anything other than "200 OK").
            let httpResponse: NSHTTPURLResponse = (response as? NSHTTPURLResponse)!
            if httpResponse.statusCode != 200 {
                print("HTTP Error")
                print(httpResponse.statusCode)
                self.dataLoadingFromAPI = false
                return
            }
            
            // Check to see that the response included data.
            guard let responseData = data else {
                print("Error: No data was found in the response.")
                self.dataLoadingFromAPI = false
                return
            }
            
            // Try to serialize the data to JSON.
            do {
                
                // Try to get the data in JSON format.
                let jsonData = try NSJSONSerialization.JSONObjectWithData(responseData, options:[]) as! NSDictionary
                
                // Get the records from the JSON data.
                if let recordsReceived = (jsonData["records"] as? [Dictionary<String,AnyObject>]) {
                    
                    // Append the records to the array.
                    self.remoteData = self.remoteData + recordsReceived
                    print(self.remoteData)
                    
                    // Reload the table.
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.restaurantsTable.reloadData()
//                    })
                    
                } else {
                    print("Error: No records received.")
                }
                
                // Get the next offset from the JSON data.
                if let offsetReceived = (jsonData["offset"] as? String) {
                    self.dataNextOffset = offsetReceived
                } else {
                    self.dataNextOffset = ""
                }
                
            } catch {
                print("Error: Unable to convert data to JSON.")
                return
            }
            
            // Flip the restaurantsLoading flag.
            self.dataLoadingFromAPI = false
            
            
        })
        
        // Start / resume the data task.
        task.resume()

    }

}
