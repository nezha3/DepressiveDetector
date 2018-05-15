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
    func drawChart(){
        //Draw chart
        let dataEntries = generateDataEntries(days: 30) //series for a month
        let dataEntries2 = generateDataEntries(days: 7)  // series for a week
        //Set data series for up chart with data in a week
        chart.dataEntries = dataEntries //below chart
        chart2.dataEntries = dataEntries2 //up chart
    }
    
    func generateDataEntries(days: Int) -> [BarEntry] {
        //NSLog("\(String(describing: currentChild?.name))") //only for test
        let colors = [UIColor.red, UIColor(displayP3Red: 0.17, green: 0.58, blue: 0.17, alpha: 1.0)]
        var result: [BarEntry] = []
        //add code for retrieve days of risks from database
        //add code for determine if dates of stored risks are less than days
        let risk = [0.5, 0.4, -0.6, -0.2, 0.7, -0.6, -0.9, 0.3, -0.4, 0.5, -0.6,0.7, -0.8, 0.9, -1.0, 0.1, -0.2, 0.3, -0.4, 0.1, -0.2, 0.3, -0.4, 0.5, -0.6,0.7, -0.8, 0.9, -1.0, 0.1, -0.2, 0.3, -0.4] //get risks from database
        for i in 0..<days {
            let value = risk[i] * 100 // time by 100 to indicate the content of risk
            let height: Float = Float(abs(value)) / 100  //justify the value of height
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM" //display date format
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i)) //add date for every risk
            var x:Int  = 1
            if (value != abs(value)) {x = 0} //determine if risk is red color
            result.append(BarEntry(color: colors[x], height: height, textValue: "\(value)", title: formatter.string(from: date)))
        }
        return result
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        drawChart()
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
    
    //Attribute from class in coredata
    //Risks of Current Child in that row of table view
    var currentRisk: Risk? {
        didSet {
            // Get risks of currentChild.
        }
    }

}

