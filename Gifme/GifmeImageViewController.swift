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
import Kingfisher

class GifmeImageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        self.view.backgroundColor = UIColor.black
        
        // Make sure the URL is safely encoded
        self.imageURL = self.imageName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed)!
        self.imageURL = "https://gif.daneden.me/" + self.imageURL
        
        // Set the image name and view title
        self.title = self.imageName
        
        // Create the progress bar view
        self.progressBar.backgroundColor = UIApplication.shared.keyWindow?.tintColor
        self.progressBarTop = (self.navigationController?.navigationBar.frame.size.height)! + (self.navigationController?.topLayoutGuide.length)!
        UIApplication.shared.keyWindow!.addSubview(self.progressBar)
        
        // Initialise the activity indicator
        initialiseViewWithActivityIndicator()
        
        // Initialise the image view
        initialiseViewWithImageView()
    }
    
    func initialiseViewWithActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
    }
    
    func initialiseViewWithImageView() {
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.imageView)
        
        let constraintEdges:[NSLayoutAttribute] = [.top, .right, .bottom, .left]
        var constraints:[NSLayoutConstraint] = []
        
        for edge in constraintEdges {
            let constraint = NSLayoutConstraint(item: self.imageView, attribute: edge, relatedBy: .equal, toItem: self.view, attribute: edge, multiplier: 1.0, constant: 0.0)
            constraints.append(constraint)
        }
        
        // Add layout constraints to the view
        self.view.addConstraints(constraints)
        
        // If we have network connectivity, load the remote image
        initialiseImageView()
    }
    
    func initialiseImageView() {
        let fullImageURL = URL(string: self.imageURL)!
        
        if(self.imageName.hasSuffix("gif")) {
            self.imageView.needsPrescaling = false
            self.imageView.framePreloadCount = 1
        }
        
        let options:KingfisherOptionsInfo = [
            .transition(ImageTransition.fade(0.25))
        ]
        
        self.imageView.kf.setImage(with: fullImageURL, placeholder: nil, options: options,
            progressBlock: { (receivedSize, totalSize) -> () in
                self.view.addSubview(self.progressBar)
                let progress = Double(Float(receivedSize)/Float(totalSize))
                self.updateProgress(progress: progress)
            },
            completionHandler: { (image, error, cacheType, imageURL) -> () in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                if(error === nil) {
                    self.showCopyingOptions()
                } else {
                    self.handleImageLoadingError(error: error!)
                }
        })
    }
    
    func updateProgress(progress: Double) {
        // progress is a percentage represented as a decimal range between 0 and 1
        if(progress==1) {
            UIView.animate(withDuration: 0.2, animations: {
                // Animate the progress bar to completion
                self.progressBar.frame = CGRect(x: 0, y: self.progressBarTop, width: self.view.frame.width, height: 2)
                }, completion: { (complete) in
                    // Wait 2 seconds then remove the progress bar
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        UIView.animate(withDuration: 0.2, animations: { 
                            self.progressBar.frame = CGRect(x: 0, y: self.progressBarTop, width: self.view.frame.width, height: 0)
                            }, completion: { (complete) in
                                self.progressBar.removeFromSuperview()
                        })
                    }
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.progressBar.frame = CGRect(x: 0, y: self.progressBarTop, width: (self.view.frame.width * CGFloat(progress)), height: 2)
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
        stackView.axis = .vertical
        
        let warningLabel = UILabel()
        warningLabel.text = message
        warningLabel.sizeToFit()
        warningLabel.textColor = UIColor.white
        warningLabel.textAlignment = .center
        stackView.addArrangedSubview(warningLabel)
        
        // Make a button to close the modal
        let dismissButton = makeButton(label: buttonText)
        stackView.addArrangedSubview(dismissButton)
        
        self.view.addSubview(stackView)
        
        let stackXConstraint = NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let stackYConstraint = NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let stackWidthConstraint = NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: -40)
        
        self.view.addConstraints([stackXConstraint, stackYConstraint, stackWidthConstraint])
        
        // Add entry animation for the button
        let stackFromValue = self.view.frame.height
        let stackAnimation = makeAnimation(property: kPOPLayoutConstraintConstant, from: stackFromValue as AnyObject?, to: 0 as AnyObject?)
        stackYConstraint.pop_add(stackAnimation, forKey: "stackEnterAnimation")
        
        // Add a gesture recogniser to the button
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        gestureRecogniser.delegate = self
        
        dismissButton.addGestureRecognizer(gestureRecogniser)
    }
    
    func showCopyingOptions() {
        // Make a button to close the modal
        let copyImageButton = makeButton(label: "Copy image")
        let copyLinkButton = makeButton(label: "Copy link")
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.addArrangedSubview(copyImageButton)
        stackView.addArrangedSubview(copyLinkButton)
        
        self.view.addSubview(stackView)
        
        let buttonXContraint = NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let buttonYConstraint = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -20.0)
        
        self.view.addConstraints([buttonXContraint, buttonYConstraint])
        
        // Add a gesture recogniser to the button
        let copyImageGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(copyImage))
        copyImageGestureRecogniser.delegate = self
        
        copyImageButton.addGestureRecognizer(copyImageGestureRecogniser)
        
        let copyLinkGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(copyURL))
        copyLinkGestureRecogniser.delegate = self
        
        copyLinkButton.addGestureRecognizer(copyLinkGestureRecogniser)
        
        let animationA = makeAnimation(property: kPOPLayerTranslationY, from: 500 as AnyObject?, to: 0 as AnyObject?)
        let animationB = makeAnimation(property: kPOPLayerTranslationY, from: 500 as AnyObject?, to: 0 as AnyObject?)
        animationB.beginTime = copyLinkButton.layer.convertTime(CACurrentMediaTime(), from: nil)+0.05
        
        copyImageButton.layer.transform = CATransform3DMakeTranslation(0, 500, 0)
        copyLinkButton.layer.transform = CATransform3DMakeTranslation(0, 500, 0)
        
        copyImageButton.layer.pop_add(animationA, forKey: "copyImageButtonAnimation")
        copyLinkButton.layer.pop_add(animationB, forKey: "copyLinkButtonAnimation")
    }
    
    func dismissModal() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func copyImage() {
        let pasteboard = UIPasteboard.general
        
        if(self.imageName.hasSuffix("gif")) {
//            let imageData = self.imageView.image?.kf.animatedImageData
            let imageData = self.imageView.image?.asData()
            pasteboard.setData(imageData!, forPasteboardType: kUTTypeGIF as String)
        } else {
            pasteboard.image = self.imageView.image
        }
        
        var style = ToastStyle()
        style.horizontalPadding = 16
        style.cornerRadius = 20
        self.view.makeToast("📸 Image copied to clipboard! 🎉", duration: 2.0, position: .center, style: style)
    }
    
    func copyURL() {
        let pasteboard = UIPasteboard.general
        let imageURL = NSURL(string: "https://gif.daneden.me/\(self.imageName)")
        pasteboard.setValue(imageURL!, forPasteboardType: kUTTypeURL as String)
        var style = ToastStyle()
        style.horizontalPadding = 16
        style.cornerRadius = 20
        self.view.makeToast("🔗 Link copied to clipboard! 🎉", duration: 2.0, position: .center, style: style)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
