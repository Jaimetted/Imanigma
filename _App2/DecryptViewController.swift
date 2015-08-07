//
//  DecryptViewController.swift
//  _App
//
//  Created by Intern McIntern on 7/10/15.
//  Copyright (c) 2015 Intern McIntern. All rights reserved.
//

import UIKit
import Parse
import CryptoSwift

class DecryptViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var randomWordsField: UITextView?
    @IBOutlet var textView: UITextView!
    @IBOutlet var revealButton: UIButton!
    @IBOutlet var pasteButton: UIButton!
    @IBOutlet var loadButton: UIButton!
    @IBOutlet var hideControllerButton: UIButton!
    @IBOutlet var revealControllerButton: UIButton!
    @IBOutlet var clearButton: UIButton!

    

    var calculator = FingerprintCalculator()
    var imagePicker = UIImagePickerController()
    var randomWords = ""
    let pasteBoard = UIPasteboard.generalPasteboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        revealButton.hidden = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        textView?.layer.borderWidth = 1.0
        textView?.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.cornerRadius = 4
        textView?.layer.cornerRadius = 4
        hideControllerButton.layer.borderWidth = 1.0
        hideControllerButton.layer.borderColor = UIColor.whiteColor().CGColor
        revealControllerButton.layer.borderWidth = 1.0
        revealControllerButton.layer.borderColor = UIColor.whiteColor().CGColor
        hideControllerButton.layer.cornerRadius = 4
        revealControllerButton.layer.cornerRadius = 4
        
        //Moves keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 250
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 250
    }
    
    //Load Photo from album - > Button (using UIImagePickerController)
    @IBAction func loadImageButtonTapped(sender: AnyObject) {
        // print("Image Loading...")
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .SavedPhotosAlbum
        self.presentViewController(imagePicker, animated: true, completion: nil)
        // println("Done")
    }
    //Paste image
    @IBAction func pasteImageButtonTapped(sender: AnyObject) {
        if var img = pasteBoard.image{
            imageView?.image = pasteBoard.image
            revealButton.hidden = false
            pasteButton.hidden = true
        }
        else{
            var alert = UIAlertController(title: "ERROR", message:"No Photo Copied", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    //Clear button
    @IBAction func clearImageButtonTapped(sender: AnyObject) {
        imageView.image = nil
        pasteButton.hidden = false
        loadButton.hidden = false
        revealButton.hidden = true
    }
    //Reveal message from image
    @IBAction func revealButtonTapped(sender: AnyObject) {
        if(randomWordsField?.text != nil){
            randomWords = randomWordsField!.text
        }

        if(imageView?.image == nil){
            var alert = UIAlertController(title: "ERROR", message:"No Photo Selected", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            var image = imageView.image
            
            
            var fingerprint: Fingerprint = self.calculator.getFingerprint(image!)
            var idToQuery = self.randomWords + String(fingerprint.getHashCode())
            var decrypted: String
            
            
            //------------------Hashing Passphrase------------------
            let randomWordsHashed: NSMutableData
            var array = [UInt8]()
            if let randomWordsHash = randomWords.sha384() {
                
                let randomWordsHashData = NSMutableData(capacity: count(randomWordsHash) / 2)
                
                for var index = randomWordsHash.startIndex; index < randomWordsHash.endIndex; index = index.successor().successor() {
                    let byteString = randomWordsHash.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
                    let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
                    randomWordsHashData?.appendBytes([num] as [UInt8], length: 1)
                }
                //   println(randomWordsHashData)
                randomWordsHashed = randomWordsHashData!
                let totalBytesRandomWords = randomWordsHashed.length
                array = [UInt8](count: totalBytesRandomWords, repeatedValue: 0)
                randomWordsHashed.getBytes(&array, length: totalBytesRandomWords)
                //  println(array.count.description + "Array 1")
            }
            //------------------Hashing Passphrase------------------
            
            
            //------------------Hashing Fingerprint------------------
            let fingerprintHashed: NSMutableData
            var array2 = [UInt8]()
            if let fingerprintHash = (fingerprint.getHashCode()).sha384() {
                
                let fingerprintHashData = NSMutableData(capacity: count(fingerprintHash) / 2)
                
                for var index = fingerprintHash.startIndex;index < fingerprintHash.endIndex; index = index.successor().successor() {
                    let byteString = fingerprintHash.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
                    let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
                    fingerprintHashData?.appendBytes([num] as [UInt8], length: 1)
                }
                //  println(fingerprintHashData)
                fingerprintHashed = fingerprintHashData!
                let totalBytesFingerprint = fingerprintHashed.length
                array2 = [UInt8](count: totalBytesFingerprint, repeatedValue: 0)
                fingerprintHashed.getBytes(&array2, length: totalBytesFingerprint)
                //  println(array2)
            }
            //------------------Hashing Fingerprint------------------
            
            
            //------------------Passphrase XOR Fingerprint = MessageKey------------------
            
            var result = [UInt8]()
            for(var i = 0;i<array2.count;++i){
                result.append(array[i] ^ array2[i] ) // append...
            }
            //  println(result)
            
            var messageKey = [UInt8]()
            var iv = [UInt8]()
            
            for(var i = 0;i<32;++i){
                messageKey.append(result[i])
            }
            for(var i = 32;i<48;++i){
                iv.append(result[i])
            }
            //   println("Message Key: " + messageKey.description)
            //   println("IV: " + iv.description)
            //------------------Passphrase XOR Fingerprint = MessageKey------------------
            
            //------------------Hashing Salt------------------
            var salt = "If nautical nonsense is something you wish..."
            let saltHashed: NSMutableData
            var arraySalt = [UInt8]()
            if let saltHash = (fingerprint.getHashCode()).sha384() {
                let saltHashData = NSMutableData(capacity: count(saltHash) / 2)
                
                for var index = saltHash.startIndex;index < saltHash.endIndex; index = index.successor().successor() {
                    let byteString = saltHash.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
                    let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
                    saltHashData?.appendBytes([num] as [UInt8], length: 1)
                }
                println(saltHashData)
                saltHashed = saltHashData!
                let totalBytesFingerprint = saltHashed.length
                arraySalt = [UInt8](count: totalBytesFingerprint, repeatedValue: 0)
                saltHashed.getBytes(&arraySalt, length: totalBytesFingerprint)
                //     println(arraySalt)
            }
            //------------------Hashing Salt------------------
            
            //------------------Salt Hash XOR MessageKey Salt------------------
            var messageIDBytes = [UInt8]()
            for(var i=0;i<48;++i){
                messageIDBytes.append(result[i] ^ arraySalt[i])
            }
            let messageIdText = NSData(bytes: messageIDBytes, length: messageIDBytes.count)
            let messageID = messageIdText.base64EncodedStringWithOptions(nil)
            println(messageID)
            //   println(messageID)
            
            
            
            
            //------------------Salt Hash XOR MessageKey Salt------------------
            
            
            
            //----------Query from Parse----------
            var query = PFQuery(className:"Post")
            query.whereKey("hash", equalTo: messageID)
            var post = query.getFirstObject()
            //   println(post?.objectForKey("message"))
            var textToDecrypt = post?.objectForKey("message") as? String//not as string...
            //----------Query from Parse----------
            println("Decryption...")
            println(messageKey)
            if textToDecrypt == nil{
                
                var alert = UIAlertController(title: "Error", message: ("No Match"), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            
            }
            else{
                
                //------------------Decryption------------------
                let aes = AES(key: messageKey, iv: iv, blockMode: .CBC)
                let aaa = NSData(base64EncodedString: textToDecrypt!, options: nil)
                let totalBytes = aaa?.length
                var array3 = [UInt8](count: totalBytes!, repeatedValue: 0)
                aaa!.getBytes(&array3, length: totalBytes!)
                
                if let aaa = aaa {
                    if let decrypted = aes?.decrypt(array3, padding: PKCS7()), resultingString = NSString(bytes: decrypted, length: decrypted.count, encoding: NSUTF8StringEncoding) {
                        //    println(resultingString)
                        textView.text = resultingString as! String
                    }
                }
                //------------------Decryption------------------
            }
        }
    }
    //Picking image from album
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject: AnyObject]) {
        var image: UIImage!
        if picker.allowsEditing {
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        } else {
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        imageView.image = image
        revealButton.hidden = false
        pasteButton.hidden = true
        loadButton.hidden = true
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //Cancel load image
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.imagePicker = UIImagePickerController()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
