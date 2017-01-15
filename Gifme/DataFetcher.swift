//
//  DataFetcher.swift
//  Gifme
//
//  Created by Daniel Eden on 5/16/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import Foundation
import Alamofire

class GifmeTag: NSObject {
    let name:String
    let associatedImageNames:Array<String>
    
    init(name:String, associatedImageNames:Array<String>) {
        self.name = name
        self.associatedImageNames = associatedImageNames
    }
}

var TagsWithGifs:[GifmeTag] = []

func testGetData() {
    let headers = [
        "Authorization": "Bearer \(AIRTABLE_API_KEY)"
    ]
    
    var tagProcessedData:[String: NSArray] = [:]
    var namesByID:[String: String] = [:]
    
    var tagData:[String: AnyObject] = [:] {
        didSet {
            createTagData(tagData)
        }
    }
    
    var nameData:[String: AnyObject] = [:] {
        didSet {
            readJSONObject(nameData)
        }
    }
    
    func readJSONObject(object: [String: AnyObject]) {
        guard let results = object["records"] as? [[String: AnyObject]] else { return }
        
        for result in results {
            guard let name = result["fields"]!["Name"] as? String,
                  let id = result["id"] as? String else {
                    print("Bad data returned from gifs table")
                    return
            }
            
            namesByID[id] = name
        }
    }
    
    func createTagData(tagsRecords: [String:AnyObject]) {
        guard let results = tagsRecords["records"] as? [[String: AnyObject]] else {
            print("Bad data returned from tags table.")
            return
        }
        
        var processed:[AnyObject] = []
        
        for result in results {
            guard let name = result["fields"]!["Name"] as? String,
                  let tags = result["fields"]!["Gifs"] as? NSMutableArray else {
                    continue
            }
            
            if(tags != []) {
                let val = [name, tags]
                processed.append(val)
            }
        }
        
        let data = NSArray(array: processed)
        
        processTagData(data)
    }
    
    func processTagData(tagData: NSArray) {
        for tag in tagData {
            for associatedImage in tag[1] {
                var imageNames = []
                if let imageName = namesByID[associatedImage] != nil {
                    imageNames.append(imageName)
                }
                
                let tag = GifmeTag(name: tag[0], associatedImageNames: imageNames)
                print(tag)
            }
        }
        
    }
    
    // Get GIF names and IDs
    Alamofire.request(.GET, "https://api.airtable.com/v0/appcHI5T0subHptj5/Gifs", headers: headers)
        .responseJSON { response in
            nameData = response.result.value as! [String: AnyObject]
            
            // When successful, get the tag names and associated images
            Alamofire.request(.GET, "https://api.airtable.com/v0/appcHI5T0subHptj5/Tags", headers: headers)
                .responseJSON { response in
                    tagData = response.result.value as! [String: AnyObject]
            }
    }
}