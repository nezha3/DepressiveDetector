//
//  ChildViewController.swift
//  DepressiveDetector
//
//  Created by Oliver Chi on 7/5/18.
//  Copyright © 2018 Oliver Chi. All rights reserved.
//

import UIKit
import CoreData

class ChildViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var twitter: UITextField!
    @IBOutlet weak var childName: UILabel!
    @IBOutlet weak var twitterAccount: UILabel!
    @IBOutlet weak var childImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var correct1: UIImageView!
    @IBOutlet weak var correct2: UIImageView!
    @IBOutlet weak var message: UILabel!
    
    //Init instance of UIImagePickController
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self

        childName.isHidden = true
        twitterAccount.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Event after click "Add New Child" button
    //To store all information about new child and display them
    //Show confirm button and cancel button
    @IBAction func addNewChild(_ sender: Any) {
        if self.name.text == "" || self.twitter.text == "" {
            self.message.text = "Please recheck inputs"
            return
        } else {
            //clear up all messages
            self.message.text = nil
            self.correct1.image = nil
            self.correct2.image = nil
        }
        
        if button.currentTitle == "Add New Child" {
            button.setTitle("Confirm", for: .normal)
            cancelBtn.setTitle("Cancel", for: .normal)
            
            childName.isHidden = false //enable label
            childName.text = name.text
            name.isHidden = true //disable textfield
            
            twitterAccount.isHidden = false //enable label
            twitterAccount.text = twitter.text
            twitter.isHidden = true //disable textfield
            
             //continue on image selector
            ////////////////////////////////////
            
        } else {
            //store information
            //save new child data into database
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Child", in: context)
            let newChild = NSManagedObject(entity: entity!, insertInto: context)
            //save name and twitterUserID
            newChild.setValue(name.text, forKey: "name")
            newChild.setValue(twitter.text, forKey: "twitterUserID")
            //add save information for image
            if childImage.image != nil {
                var newImage = childImage.image
                //change childImage aspect to 4:3
                newImage = resizedImage(image: newImage!, newSize: CGSize(width: 160, height: 120))
                let randomName = random(10)
                //NSLog("childImageName: "+"\(randomName)") //only for test
                saveImageforChild(image: newImage!, fileName: randomName) //childImage.image!
                newChild.setValue(randomName, forKey: "imageName")
            } else{
                //add codes for save nil image metadata in database
                 //NSLog("no Child Image") //only for testing
                newChild.setValue("", forKey: "imageName")
            }
            //save other attributes as initial values
            newChild.setValue(0, forKey: "twitterSinceID")
            newChild.setValue(Date(), forKey: "lastAccessDate")
            newChild.setValue(0.0, forKey: "currentMood")
            newChild.setValue(false, forKey: "ifAlert")

            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            //restore all elements
            button.setTitle("Add New Child", for: .normal)
            cancelBtn.setTitle("Go Back", for: .normal)
            name.isHidden = false
            name.text = ""
            childName.isHidden = true
            childName.text = ""
            twitter.isHidden = false
            twitter.text = ""
            twitterAccount.isHidden = true
            twitterAccount.text = ""
            
            //go back
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Func: Random Words
    func random(_ n: Int) -> String {
        let a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        var s = ""
        for _ in 0..<n {
            let r = Int(arc4random_uniform(UInt32(a.count)))
            s += String(a[a.index(a.startIndex, offsetBy: r)])
        }
        return s
    }
    
    //Change image aspect
    //Returns a image that fills in newSize
    func resizedImage(image: UIImage, newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard image.size != newSize else { return image}
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //Save Child image
    func saveImageforChild(image: UIImage, fileName: String){
        //let fileName = "child1" //need to specified name for image
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocumentDirURL.appendingPathComponent("imageforChild").appendingPathComponent(fileName).appendingPathExtension("png")
        
        let data = UIImagePNGRepresentation(image)
        do {
            try data?.write(to: fileURL)
        } catch {
             NSLog("failed with error: \(error)")
        }
    }
    
    //Cancel inputs on textfields
    //Disable cancel button and two UILabel
    @IBAction func cancelAction(_ sender: Any) {
        if cancelBtn.currentTitle == "Go Back" {
            self.dismiss(animated: true, completion: nil) //go back without any passing data
        } else {
            button.setTitle("Add New Child", for: .normal)
            cancelBtn.setTitle("Go Back", for: .normal)
            
            childName.isHidden = true //disable label
            childName.text = ""
            name.isHidden = false //enable textfield
            name.text = ""
            
            twitterAccount.isHidden = true //disable label
            twitterAccount.text = ""
            twitter.isHidden = false //enable textfield
            twitter.text = ""
        }
    }
    
    //Autocorrection on input on textField "name"
    @IBAction func textChanged1(_ sender: Any) {
        if let text = name.text {
            if text != ""{
                self.correct1.image = #imageLiteral(resourceName: "correct")
            } else {
                self.correct1.image = nil
            }
        }
    }
    
    //Autocorrection on input on textField "twitter"
    @IBAction func textChange2(_ sender: Any) {
        if let text = twitter.text {
            if text != ""{
                self.correct2.image = #imageLiteral(resourceName: "correct")
            } else {
                self.correct2.image = nil
            }
        }
    }
    
    
    
    //Popover photo library to select a photo for child
    @IBAction func selectChildPhoto(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            childImage.contentMode = .scaleAspectFit
            childImage.image = pickedImage
            childImage.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
