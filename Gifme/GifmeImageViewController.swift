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
import Toast_Swift

class GifmeImageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    var imageView:AnimatedImageView = AnimatedImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var imageURL:String = ""
    var imageName:String = ""
    
    var progressBarTop = CGFloat(0)
    let progressBar = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 2))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tell the activity indicator to hide when stopped
        self.activityIndicator.hidesWhenStopped = true
        
        // Set the view's background color
        self.view.backgroundColor = UIColor.blackColor()
        
        // Make sure the URL is safely encoded
        self.imageURL = self.imageName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
        self.imageURL = "https://gif.daneden.me/" + self.imageURL
        
        // Set the image name and view title
        self.title = self.imageName
        
        // Create the progress bar view
        self.progressBar.backgroundColor = UIApplication.sharedApplication().keyWindow?.tintColor
        self.progressBarTop = (self.navigationController?.navigationBar.frame.size.height)! + (self.navigationController?.topLayoutGuide.length)!
        UIApplication.sharedApplication().keyWindow!.addSubview(self.progressBar)
        
        // Initialise the activity indicator
        initialiseViewWithActivityIndicator()
        
        // Initialise the image view
        initialiseViewWithImageView()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func initialiseViewWithActivityIndicator() {
        self.activityIndicator.center = self.view.center
        
        self.activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
    }
    
    func initialiseViewWithImageView() {
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
        
        // If we have network connectivity, load the remote image
        initialiseImageView()
    }
    
    func initialiseImageView() {
        let fullImageURL = NSURL(string: self.imageURL)!
        
        if(self.imageName.hasSuffix("gif")) {
            self.imageView.needsPrescaling = false
        }
        
        let options:KingfisherOptionsInfo = [
            .Transition(ImageTransition.Fade(0.25))
        ]
        
        self.imageView.kf_setImageWithURL(fullImageURL, placeholderImage: nil, optionsInfo: options,
            progressBlock: { (receivedSize, totalSize) -> () in
                self.view.addSubview(self.progressBar)
                let progress = Double(Float(receivedSize)/Float(totalSize))
                self.updateProgress(progress)
            },
            completionHandler: { (image, error, cacheType, imageURL) -> () in
                self.activityIndicator.stopAnimating()
                if(error === nil) {
                    self.showCopyingOptions()
                } else {
                    let err = error
                    self.handleImageLoadingError(err!)
                }
        })
    }
    
    func updateProgress(progress: Double) {
        // progress is a percentage represented as a decimal range between 0 and 1
        if(progress==1) {
            UIView.animateWithDuration(0.2, animations: {
                // Animate the progress bar to completion
                self.progressBar.frame = CGRectMake(0, self.progressBarTop, self.view.frame.width, 2)
                }, completion: { (complete) in
                    // Wait 2 seconds then remove the progress bar
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2)), dispatch_get_main_queue(), { 
                        UIView.animateWithDuration(0.2, animations: { 
                            self.progressBar.frame = CGRectMake(0, self.progressBarTop, self.view.frame.width, 0)
                            }, completion: { (complete) in
                                self.progressBar.removeFromSuperview()
                        })
                    })
            })
        } else {
            UIView.animateWithDuration(0.2, animations: {
                self.progressBar.frame = CGRectMake(0, self.progressBarTop, (self.view.frame.width * CGFloat(progress)), 2)
                }, completion: nil)
        }
    }
    
    func handleImageLoadingError(error: NSError) {
        // If we run into an error, let the user back out
        var message = "Hmm. Something went wrong."
        var buttonText = "Bummer"
        
        // If the error is a network connectivity problem
        if (error.code == -1009) {
            message = "Unable to connect to network"
            buttonText = "Well ok then"
        }
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        stackView.axis = .Vertical
        
        let warningLabel = UILabel()
        warningLabel.text = message
        warningLabel.sizeToFit()
        warningLabel.textColor = UIColor.whiteColor()
        warningLabel.textAlignment = .Center
        stackView.addArrangedSubview(warningLabel)
        
        // Make a button to close the modal
        let dismissButton = makeButton(buttonText)
        stackView.addArrangedSubview(dismissButton)
        
        self.view.addSubview(stackView)
        
        let stackXConstraint = NSLayoutConstraint(item: stackView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let stackYConstraint = NSLayoutConstraint(item: stackView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        let stackWidthConstraint = NSLayoutConstraint(item: stackView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: -40)
        
        self.view.addConstraints([stackXConstraint, stackYConstraint, stackWidthConstraint])
        
        // Add entry animation for the button
        let stackFromValue = self.view.frame.height
        let stackAnimation = makeAnimation(kPOPLayoutConstraintConstant, from: stackFromValue, to: 0)
        stackYConstraint.pop_addAnimation(stackAnimation, forKey: "stackEnterAnimation")
        
        // Add a gesture recogniser to the button
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        gestureRecogniser.delegate = self
        
        dismissButton.addGestureRecognizer(gestureRecogniser)
    }
    
    func showCopyingOptions() {
        // Make a button to close the modal
        let copyImageButton = makeButton("Copy image")
        let copyLinkButton = makeButton("Copy link")
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.addArrangedSubview(copyImageButton)
        stackView.addArrangedSubview(copyLinkButton)
        
        self.view.addSubview(stackView)
        
        let buttonXContraint = NSLayoutConstraint(item: stackView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let buttonYConstraint = NSLayoutConstraint(item: stackView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -20.0)
        
        self.view.addConstraints([buttonXContraint, buttonYConstraint])
        
        // Add a gesture recogniser to the button
        let copyImageGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(copyImage))
        copyImageGestureRecogniser.delegate = self
        
        copyImageButton.addGestureRecognizer(copyImageGestureRecogniser)
        
        let copyLinkGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(copyURL))
        copyLinkGestureRecogniser.delegate = self
        
        copyLinkButton.addGestureRecognizer(copyLinkGestureRecogniser)
        
        let animationA = makeAnimation(kPOPLayerTranslationY, from: 500, to: 0)
        let animationB = makeAnimation(kPOPLayerTranslationY, from: 500, to: 0)
        animationB.beginTime = copyLinkButton.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)+0.05
        
        copyImageButton.layer.transform = CATransform3DMakeTranslation(0, 500, 0)
        copyLinkButton.layer.transform = CATransform3DMakeTranslation(0, 500, 0)
        
        copyImageButton.layer.pop_addAnimation(animationA, forKey: "copyImageButtonAnimation")
        copyLinkButton.layer.pop_addAnimation(animationB, forKey: "copyLinkButtonAnimation")
    }
    
    func dismissModal() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func copyImage() {
        let pasteboard = UIPasteboard.generalPasteboard()
        
        if(self.imageName.hasSuffix("gif")) {
            let imageData = self.imageView.image?.kf_animatedImageData
            pasteboard.setData(imageData!, forPasteboardType: kUTTypeGIF as String)
        } else {
            pasteboard.image = self.imageView.image
        }
        
        var style = ToastStyle()
        style.horizontalPadding = 16
        style.cornerRadius = 20
        self.view.makeToast("📸 Image copied to clipboard! 🎉", duration: 2.0, position: .Center, style: style)
    }
    
    func copyURL() {
        let pasteboard = UIPasteboard.generalPasteboard()
        let imageURL = NSURL(string: "https://gif.daneden.me/\(self.imageName)")
        pasteboard.setValue(imageURL!, forPasteboardType: kUTTypeURL as String)
        var style = ToastStyle()
        style.horizontalPadding = 16
        style.cornerRadius = 20
        self.view.makeToast("🔗 Link copied to clipboard! 🎉", duration: 2.0, position: .Center, style: style)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
