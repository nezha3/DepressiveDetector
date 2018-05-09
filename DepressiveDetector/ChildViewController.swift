//
//  ChildViewController.swift
//  DepressiveDetector
//
//  Created by Oliver Chi on 7/5/18.
//  Copyright © 2018 Oliver Chi. All rights reserved.
//

import UIKit
import CoreData

class ChildViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var twitter: UITextField!
    @IBOutlet weak var childName: UILabel!
    @IBOutlet weak var twitterAccount: UILabel!
    @IBOutlet weak var childImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            newChild.setValue(name.text, forKey: "name")
            newChild.setValue(twitter.text, forKey: "twitterAccount")
            //add save information for image
            ///////////////////////////////////////
            
        
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
            //continue on image selector
            ////////////////////////////////////
            
            //go back
            self.dismiss(animated: true, completion: nil)
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
            
            //continue on image selector
        }
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
