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
    
    var imageView:UIImageView! = UIImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var imageURL:String = ""
    var imageName:String = ""
    
    let progressBar = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 4))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let imageName = self.imageURL.componentsSeparatedByString("/")
        self.imageName = imageName.last!
        self.title = self.imageName
        
        self.progressBar.backgroundColor = UIApplication.sharedApplication().keyWindow?.tintColor
        self.view.addSubview(self.progressBar)

        
        // Initialise an activity indicator
        initialiseViewWithActivityIndicator()
        
        // Initialise the image view
        initialiseViewWithImageView(self.imageURL)
        
        ToastManager.shared.queueEnabled = false
        
        // If we have network connectivity, load the remote image
        initialiseImageView()
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
    
    func initialiseImageView() {
        let fullImageURL = NSURL(string: self.imageURL)
        
        let options:KingfisherOptionsInfo = [
            KingfisherOptionsInfoItem.Transition(ImageTransition.Fade(0.25)),
            KingfisherOptionsInfoItem.PreloadAllGIFData
        ]
        
        self.imageView.kf_setImageWithURL(fullImageURL!, placeholderImage: nil, optionsInfo: options,
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
                    self.handleImageLoadingError()
                }
        })
    }
    
    func updateProgress(progress: Double) {
        // progress is a percentage represented as a decimal range between 0 and 1
        if(progress==1) {
            UIView.animateWithDuration(0.5, animations: { 
                self.progressBar.frame = CGRectMake(0, (self.navigationController?.navigationBar.frame.height)!+20, self.view.frame.width, 0)
                }, completion: { (complete) in
                    self.progressBar.removeFromSuperview()
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.progressBar.frame = CGRectMake(0, (self.navigationController?.navigationBar.frame.height)!+20, (self.view.frame.width * CGFloat(progress)), 4)
                }, completion: nil)
        }
    }
    
    func handleImageLoadingError() {
        // If we don't have network connectivity, let the user know what's up
        // Throw in our helpful label
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        stackView.axis = .Vertical
        
        let warningLabel = UILabel()
        warningLabel.text = "Unable to connect to network."
        warningLabel.sizeToFit()
        warningLabel.textColor = UIColor.whiteColor()
        stackView.addArrangedSubview(warningLabel)
        
        // Add entry animation for the label
        let labelFromValue = warningLabel.frame.origin.y + 40
        let labelToValue = warningLabel.frame.origin.y
        let labelAnimation = makeAnimation(kPOPLayerPositionY, from: labelFromValue, to: labelToValue)
        labelAnimation.beginTime = (CACurrentMediaTime() + 0.25)
//        labelAnimation.springSpeed = 15
        warningLabel.pop_addAnimation(labelAnimation, forKey: "labelEnterAnimation")
        
        // Make a button to close the modal
        let dismissButton = makeButton("Well ok then")
        stackView.addArrangedSubview(dismissButton)
        
        self.view.addSubview(stackView)
        
        let stackXConstraint = NSLayoutConstraint(item: stackView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let stackYConstraint = NSLayoutConstraint(item: stackView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraints([stackXConstraint, stackYConstraint])
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
