//
//  PhotoViewController.swift
//  _App
//
//  Created by Intern McIntern on 7/10/15.
//  Copyright (c) 2015 Intern McIntern. All rights reserved.
//
import UIKit

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
    }
    
    @IBAction func loadImageButtonTapped(sender: AnyObject) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .SavedPhotosAlbum
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject: AnyObject]) {
        
        var image: UIImage!
        
        // fetch the selected image
        if picker.allowsEditing {
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        } else {
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        
        // Do something about image by yourself
        
        // dissmiss the image picker controller window
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.imagePicker = UIImagePickerController()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
