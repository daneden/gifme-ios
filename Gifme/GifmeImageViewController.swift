//
//  GifmeImageViewController.swift
//  Gifme
//
//  Created by Daniel Eden on 4/24/16.
//  Copyright © 2016 Daniel Eden. All rights reserved.
//

import UIKit

class GifmeImageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var imageView:UIImageView! = UIImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
