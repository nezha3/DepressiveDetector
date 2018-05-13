//
//  DetailViewController.swift
//  DepressiveDetector
//
//  Created by Oliver Chi on 7/5/18.
//  Copyright © 2018 Oliver Chi. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var childName: UILabel!
    
    func configureView() {
        // Update the user interface for items.
        if let child = currentChild {
            if let label = childName {
                label.text?.append(child.name!) //add child name for title 
            }
        }
        
        //add more details for items
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Attribute from class in coredata
    //Current Child in that row of table view
    var currentChild: Child? {
        didSet {
            // Update the view.
            configureView()
        }
    }

}

