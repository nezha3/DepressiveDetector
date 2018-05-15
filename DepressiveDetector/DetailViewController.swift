//
//  DetailViewController.swift
//  DepressiveDetector
//
//  Created by Oliver Chi on 7/5/18.
//  Copyright © 2018 Oliver Chi. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController{

    @IBOutlet weak var chart: BasicBarChart!
    @IBOutlet weak var chart2: BeautifulBarChart!
    @IBOutlet weak var childName: UILabel!
    
   
    func configureView() {
        // Update the user interface for items.
        if let child = currentChild {
            if let label = childName {
                label.text?.append(child.name!) //add child name for title 
            }
        }
    }
    
    func generateDataEntries() -> [BarEntry] {
        let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), UIColor.black]
        var result: [BarEntry] = []
        let risk = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6,0.7, 0.8, 0.9, 1.0, 0.1, 0.2, 0.3, 0.4] //get risks from database
        for i in 0..<risk.count {
            let value = risk[i]
            let height: Float = Float(value) //justify the value of height
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM" //display date format
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i)) //add date for every risk
            result.append(BarEntry(color: colors[i % colors.count], height: height, textValue: "\(value)", title: formatter.string(from: date)))
        }
        return result
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        //Draw chart
        let dataEntries = generateDataEntries()
        chart.dataEntries = dataEntries //below chart
        chart2.dataEntries = dataEntries //up chart
    }
    
    //Transition Display
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        //chart.setNeedsDisplay()
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

