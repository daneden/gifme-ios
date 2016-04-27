//
//  GifmeImageViewController.swift
//  Gifme
//
//  Created by Daniel Eden on 4/24/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit
import pop

class GifmeImageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var imageView:UIImageView! = UIImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var imageURL:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        // Initialise an activity indicator
        initialiseViewWithActivityIndicator()
        
        // Initialise the image view
        initialiseViewWithImageView(self.imageURL)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        initialiseImageView()
    }
    
    func initialiseViewWithActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        activityIndicator.center = self.view.center
        
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
    }
    
    func initialiseViewWithImageView(imageURL:String) {
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        gestureRecogniser.delegate = self
        
        imageView.userInteractionEnabled = true
        
        imageView.addGestureRecognizer(gestureRecogniser)
        
        self.view.addSubview(self.imageView)
        
        let imageViewTopConstraint = NSLayoutConstraint(item: self.imageView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let imageViewRightConstraint = NSLayoutConstraint(item: self.imageView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let imageViewBottomConstraint = NSLayoutConstraint(item: self.imageView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let imageViewLeftConstraint = NSLayoutConstraint(item: self.imageView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        // Add layout constraints to the view
        self.view.addConstraints([imageViewTopConstraint, imageViewRightConstraint, imageViewBottomConstraint, imageViewLeftConstraint])
    }
    
    func initialiseImageView() {
        var image:UIImage
        
        if self.imageURL.hasSuffix(".gif") {
            image = UIImage.gifWithURL(self.imageURL)!
            self.imageView.image = image
        } else {
            let imageURL = NSURL(string: self.imageURL)
            self.imageView.hnk_setImageFromURL(imageURL!)
        }
    }
    
    func dismissModal() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
