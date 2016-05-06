//
//  GifmeImageViewController.swift
//  Gifme
//
//  Created by Daniel Eden on 4/24/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit
import pop
import AVKit
import MobileCoreServices

class GifmeImageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    var imageView:UIImageView! = UIImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var imageURL:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let imageName = self.imageURL.componentsSeparatedByString("/")
        self.title = imageName.last
        
        // Initialise an activity indicator
        initialiseViewWithActivityIndicator()
        
        // Initialise the image view
        initialiseViewWithImageView(self.imageURL)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if Reachability.connectedToNetwork() {
            // If we have network connectivity, load the remote image
            initialiseImageView()
        } else {
            // If we don't have network connectivity, let the user know what's up
            // Stop animating and remove the activity indicator
            self.activityIndicator.stopAnimating()
            
            // Throw in our helpful label
            let warningLabel = UILabel()
            warningLabel.text = "Unable to connect to network."
            warningLabel.frame.size.width = (self.view.frame.width - 40)
            warningLabel.center = self.view.center
            warningLabel.textColor = UIColor.whiteColor()
            warningLabel.textAlignment = NSTextAlignment.Center
            self.view.addSubview(warningLabel)
            
            // Add entry animation for the label
            let labelAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            labelAnimation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x, self.view.frame.height + 100))
            labelAnimation.toValue = NSValue(CGPoint: warningLabel.center)
            labelAnimation.springSpeed = 15
            labelAnimation.springBounciness = 6
            warningLabel.pop_addAnimation(labelAnimation, forKey: "labelEnterAnimation")
            
            // Make a button to close the modal
            let dismissButton = makeButton("Well ok then")
            dismissButton.center = self.view.center
            dismissButton.frame.origin.x = (self.view.frame.width/2) - (dismissButton.frame.width/2)
            dismissButton.frame.origin.y = ((self.view.frame.height/2) - (dismissButton.frame.height/2)) + 60
            self.view.addSubview(dismissButton)
            
            // Add entry animation for the button
            let fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x, self.view.frame.height + 100))
            let toValue = NSValue(CGPoint: dismissButton.center)
            let buttonAnimation = makeAnimation(kPOPViewCenter, from: fromValue, to: toValue)
            dismissButton.pop_addAnimation(buttonAnimation, forKey: "buttonEnterAnimation")
            
            // Add a gesture recogniser to the button
            let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
            gestureRecogniser.delegate = self
            
            dismissButton.addGestureRecognizer(gestureRecogniser)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func initialiseViewWithActivityIndicator() {
        self.activityIndicator.center = self.view.center
        
        self.activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
    }
    
    func initialiseViewWithImageView(imageURL:String) {
        if self.imageURL.hasSuffix(".gif") {
            self.imageView = AnimatedImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.imageView)
        
        let constraintEdges:[NSLayoutAttribute] = [.Top, .Right, .Bottom, .Left]
        var constraints:[NSLayoutConstraint] = []
        
        for edge in constraintEdges {
            let constraint = NSLayoutConstraint(item: self.imageView, attribute: edge, relatedBy: .Equal, toItem: self.view, attribute: edge, multiplier: 1.0, constant: 0.0)
            constraints.append(constraint)
        }
        
        // Add layout constraints to the view
        self.view.addConstraints(constraints)
    }
    
    func initialiseImageView() -> Bool {
        let imageURL = NSURL(string: self.imageURL)
        
        self.imageView.kf_setImageWithURL(imageURL!, placeholderImage: nil, optionsInfo: nil, progressBlock: nil,
            completionHandler: { (image, error, cacheType, imageURL) -> () in
                self.showCopyingOptions()
                self.activityIndicator.stopAnimating()
        })
        
        return true
    }
    
    func showCopyingOptions() {
        // Make a button to close the modal
        let button = makeButton("Copy image")
        
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonXContraint = NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let buttonYConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -20.0)
        
        self.view.addConstraints([buttonXContraint, buttonYConstraint])
        
        // Add entry animation for the button
        let buttonAnimation = makeAnimation(kPOPLayoutConstraintConstant, from: 200.0, to: 20.0)
        buttonYConstraint.pop_addAnimation(buttonAnimation, forKey: "buttonEnterAnimation")
        
        // Add a gesture recogniser to the button
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(copyImage))
        gestureRecogniser.delegate = self
        
        button.addGestureRecognizer(gestureRecogniser)
    }
    
    func dismissModal() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func copyImage() {
        let pasteboard = UIPasteboard.generalPasteboard()
        let imageData = self.imageView.image?.kf_animatedImageData
        pasteboard.setData(imageData!, forPasteboardType: kUTTypeGIF as String)
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
