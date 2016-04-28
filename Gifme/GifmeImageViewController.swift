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
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let warningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    let button = GifmeButton(type: .Custom)
    
    var imageView:UIImageView! = UIImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var imageURL:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.activityIndicator.hidesWhenStopped = true
        
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
            self.warningLabel.text = "Unable to connect to network."
            self.warningLabel.frame.size.width = (self.view.frame.width - 40)
            self.warningLabel.center = self.view.center
            self.warningLabel.textColor = UIColor.whiteColor()
            self.warningLabel.textAlignment = NSTextAlignment.Center
            self.view.addSubview(self.warningLabel)
            
            // Add entry animation for the label
            let labelAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            labelAnimation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x, self.view.frame.height + 100))
            labelAnimation.toValue = NSValue(CGPoint: self.warningLabel.center)
            labelAnimation.springSpeed = 15
            labelAnimation.springBounciness = 6
            self.warningLabel.pop_addAnimation(labelAnimation, forKey: "labelEnterAnimation")
            
            // Make a button to close the modal
            self.button.setTitle("Well ok then", forState: .Normal)
            self.button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.button.backgroundColor = self.view.tintColor
            self.button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            
            self.button.sizeToFit()
            self.button.layer.cornerRadius = (self.button.frame.height/2)
            
            self.button.frame.origin.x = (self.view.frame.width/2) - (self.button.frame.width/2)
            self.button.frame.origin.y = ((self.view.frame.height/2) - (self.button.frame.height/2)) + 60
            self.view.addSubview(self.button)
            
            // Add entry animation for the button
            let buttonAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            buttonAnimation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x, self.view.frame.height + 100))
            buttonAnimation.toValue = NSValue(CGPoint: self.button.center)
            buttonAnimation.springSpeed = 10
            buttonAnimation.springBounciness = 6
            self.button.pop_addAnimation(buttonAnimation, forKey: "buttonEnterAnimation")
            
            // Add a gesture recogniser to the button
            let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
            gestureRecogniser.delegate = self
            
            self.button.addGestureRecognizer(gestureRecogniser)
        }
    }
    
    func initialiseViewWithActivityIndicator() {
        self.activityIndicator.center = self.view.center
        
        self.activityIndicator.startAnimating()
        
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
