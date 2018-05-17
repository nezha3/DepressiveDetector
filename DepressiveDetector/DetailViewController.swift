//
//  DetailViewController.swift
//  DepressiveDetector
//
//  Created by Oliver Chi on 7/5/18.
//  Copyright © 2018 Oliver Chi. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import Foundation

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
        
        //retrieve twitter and google ML cloud
        let userID = "dropaphone"
        // retrieveTwitter(twitterId:userID,sinceId: "983456300179783680")
        retrieveTwitter(twitterId:userID,sinceId:nil)
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

    
    func gcRequest(text : String, since_id : String, create_date : String) {
        //let urlAuthen = "https://api.twitter.com/oauth2/token";
        let urlAuthen = "https://language.googleapis.com/v1/documents:analyzeSentiment?key=AIzaSyAGwAOOPRKjSDxQZj4WJUhYM8zHTElywjI";
        
        let parameters: Parameters = [
            "encodingType": "UTF8",
            "document": [
                "type": "PLAIN_TEXT",
                "content": text,
            ]
        ]
        
        
        Alamofire.request(urlAuthen, method: .post, parameters: parameters,encoding: JSONEncoding.default).responseJSON
            { (response:DataResponse) in
                switch response.result {
                case .success(let value):
                    let jsonAuthen = JSON(value)
                    //print(jsonAuthen)
                    print("==========================")
                    print("twitter_id: \(since_id)")
                    print("create_time: \(create_date)")
                    print("twitter_content: \(text)")
                    print("magnitude: \(jsonAuthen["documentSentiment"]["magnitude"])")
                    print("score: \(jsonAuthen["documentSentiment"]["score"])")
                    print("\n")
                case .failure(let error):
                    print(error)
                    return
                }
        }
        
    }
    
    
    let twitterID = "dropaphone"
    func retrieveTwitter(twitterId:String,sinceId:String?) {
        let customerKey = "ZfyJo2mBTk1ZZELJRe7soNAyz"
        let customerSecret = "fOuA7PwFBrU64zX0ahlu7wiFPzXmN3xaHJFENAC0wVu71VZFrd"
        let keyValue = "\(customerKey):\(customerSecret)"
        let utf8strKey = keyValue.data(using: String.Encoding.utf8)
        let base64Encoded = utf8strKey!.base64EncodedString();
        let authen = "Basic \(String(describing: base64Encoded))";
        let urlAuthen = "https://api.twitter.com/oauth2/token";
        let urlTimeLine = "https://api.twitter.com/1.1/statuses/user_timeline.json";
        let headers = ["Authorization" : authen,
                       "Content-Type": "application/x-www-form-urlencoded"]
        let parameters: Parameters = ["grant_type": "client_credentials"]
        
        
        Alamofire.request(urlAuthen, method: .post, parameters: parameters,headers: headers).responseJSON
            { (response:DataResponse) in
                switch response.result {
                case .success(let value):
                    let jsonAuthen = JSON(value)
                    let token = jsonAuthen["access_token"].description
                    print("Token: \(token)")
                    var parametersTimeLine : Parameters = Parameters();
                    parametersTimeLine["screen_name"] = twitterId;
                    if (sinceId != nil)
                    {
                        parametersTimeLine["since_id"] = sinceId;
                    }
                    
                    
                    // let parametersTimeLine: Parameters = ["screen_name": twitterID,
                    //                                       "since_id":"983456300179783680"]
                    // let parametersTimeLine: Parameters = ["screen_name": twitterId]
                    
                    let timeLineAuthen = "Bearer \(token)";
                    let headersTimeLine = ["Authorization" : timeLineAuthen]
                    
                    Alamofire.request(urlTimeLine, parameters: parametersTimeLine,headers: headersTimeLine).responseJSON
                        {
                            (response1:DataResponse) in
                            switch response1.result {
                            case .success(let value):
                                let json = JSON(value)
                                for twitter in json.arrayValue
                                {
                                    // print("==========================")
                                    // print("since_id: \(twitter["id"].description)")
                                    // print("create_time: \(twitter["created_at"].description)")
                                    // print("twitter_content: \(twitter["text"].description)")
                                    // print("\n")
                                    self.gcRequest(text: twitter["text"].description, since_id:  twitter["id"].description,create_date:  twitter["created_at"].description)
                                    
                                }
                            case .failure(let error):
                                print(error)
                            }
                    }
                    
                case .failure(let error):
                    print(error)
                    return
                }
        }
    }
}

