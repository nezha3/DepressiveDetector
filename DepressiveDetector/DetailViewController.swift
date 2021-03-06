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

//Convert String to Date
extension String {
    func toDate( dateFormat format  : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.date(from: self)!
    }
}

//Convert Date to String
extension Date {
    func toString( dateFormat format  : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

class DetailViewController: UIViewController{

    @IBOutlet weak var chart: BasicBarChart!
    @IBOutlet weak var chart2: BeautifulBarChart!
    @IBOutlet weak var childName: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var middleImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
   
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
    
    func configureMoodPanel(){
        //Display current mood
        if let mood = currentChild?.currentMood {
            let moodInt = Int(mood * 100)
            leftLabel?.text = "\(moodInt)"
            switch mood {
            case 0.0 ..< 0.3:
                leftImage?.image = #imageLiteral(resourceName: "face4")
                leftLabel?.textColor = UIColor.green
            case 0.3 ..< 0.6:
                leftImage?.image = #imageLiteral(resourceName: "face5")
                leftLabel?.textColor = UIColor.green
            case 0.6 ..< 1.1:
                leftImage?.image = #imageLiteral(resourceName: "face6")
                leftLabel?.textColor = UIColor.green
            case -0.3 ..< 0.0:
                leftImage?.image = #imageLiteral(resourceName: "face3")
                leftLabel?.textColor = UIColor.red
            case -0.6 ..< -0.3:
                leftImage?.image = #imageLiteral(resourceName: "face2")
                leftLabel?.textColor = UIColor.red
            case -1.1 ..< -0.6:
                leftImage?.image = #imageLiteral(resourceName: "face1")
                leftLabel?.textColor = UIColor.red
            default:
                NSLog("currentMood(-1~1) in Alert of database is in a wrong range")
            }
        }
        
        //Display Alert Indicator
        if let alert = currentChild?.ifAlert {
            if alert == true {
                rightLabel?.textColor = UIColor.red
                rightLabel?.text = "extreme risk"
                rightImage?.image = #imageLiteral(resourceName: "alert_true")
            } else {
                rightLabel?.textColor = UIColor.green
                rightLabel?.text = "low risk"
                rightImage?.image = #imageLiteral(resourceName: "alert_false")
            }
        }
        
        //Display Twitter Last Post Days
        if let twitterMissingDays = currentChild?.twitterMissingDays {
            switch twitterMissingDays {
            case 0:
                middleImage?.image = #imageLiteral(resourceName: "twitter_green")
                middleLabel?.text = "current"
                middleLabel?.textColor = UIColor.green
            case 1:
                middleImage?.image = #imageLiteral(resourceName: "twitter_green")
                middleLabel?.text = "1 day miss"
                middleLabel?.textColor = UIColor.green
            case 2..<4:
                middleImage?.image = #imageLiteral(resourceName: "twitter_green")
                middleLabel?.text = "\(twitterMissingDays)" + " days miss"
                middleLabel?.textColor = UIColor.green
            case 4..<8:
                middleImage?.image = #imageLiteral(resourceName: "twitter_red")
                middleLabel?.text = "\(twitterMissingDays)" + " days miss"
                middleLabel?.textColor = UIColor.red
            case 8..<30:
                middleImage?.image = #imageLiteral(resourceName: "twitter_red")
                middleLabel?.text = "> week miss"
                middleLabel?.textColor = UIColor.red
            case 30..<365:
                middleImage?.image = #imageLiteral(resourceName: "twitter_red")
                middleLabel?.text = "> month miss"
                middleLabel?.textColor = UIColor.red
            default:
                middleImage?.image = #imageLiteral(resourceName: "twitter_red")
                middleLabel?.text = "no twitter at all"
                middleLabel?.textColor = UIColor.red
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        //retrieve twitter and google ML cloud
        //let userID = "dropaphone"
        // retrieveTwitter(twitterId:userID,sinceId: "983456300179783680")
        // retrieveTwitter(twitterId:userID,sinceId:nil)
        if (currentChild?.twitterSinceID == 0) {
            retrieveTwitter(twitterId: (currentChild?.twitterUserID)!,sinceId: nil)
        } else {
            retrieveTwitter(twitterId:  (currentChild?.twitterUserID)!,sinceId: "\( (currentChild?.twitterSinceID)!)")
        }
        
        //set mood panel
        configureMoodPanel()
        
        //draw the charts
        drawChart()
        
        //set mood panel again after retrieve new twitter posts
        configureMoodPanel()
        
        //draw the charts with changes
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
    
    
    
    func generateDataEntries(days: Int) -> [BarEntry] {
        //colors for bar
        let colors = [UIColor.red, UIColor(displayP3Red: 0.17, green: 0.58, blue: 0.17, alpha: 1.0)]
        var result: [BarEntry] = []
        
        //add code for retrieve days of risks from database
        //add code for determine if dates of stored risks are less than days
        //let risk = [0.5, 0.4, -0.6, -0.2, 0.7, -0.6, -0.9, 0.3, -0.4, 0.5, -0.6,0.7, -0.8, 0.9, -1.0, 0.1, -0.2, 0.3, -0.4, 0.1, -0.2, 0.3, -0.4, 0.5, -0.6,0.7, -0.8, 0.9, -1.0, 0.1, -0.2, 0.3, -0.4] //get risks from database
        let risks = getRisks(name: (currentChild?.name)!)
        
        var risk: [Float] = []
        var date: [Date] = []
        //get all available (date, risk)
        for i in 0..<risks.count{
            date.append(risks[i].0)
            risk.append(risks[i].1)
        }
        
        //check if need an alert
        //set value of current mood
        //set value of twitter days
        if risk != [] {
            checkifAlert(risk: risk, date: date)
        }
        
        //check if days is less than required
        var newdays = days
        if days > risks.count {
            newdays = risks.count
        }
        
        for i in 0..<newdays {
            let value = Int(risk[i] * 100) // time by 100 to indicate the content of risk
            let height: Float = Float(abs(value)) / 100  //justify the value of height
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM" //display date format
            //date.addTimeInterval(TimeInterval(24*60*60*i)) //add date for every risk
            
            var x:Int  = 1
            if (value != abs(value)) {x = 0} //determine if risk is red color
            
            result.append(BarEntry(color: colors[x], height: height, textValue: "\(value)", title: formatter.string(from: date[i])))
        }
        return result
    }
    
    
    //check if need an alert
    //set value of current mood
    //set value of twitter days
    func checkifAlert(risk: [Float], date: [Date]) -> Void {
        var currentMood: Float = 0.0
        var risksCount:Int = 0 //how many risks in one day
        for i in 0..<risk.count {
            if date[0] <= Date(timeInterval: 86400, since: date[i]){
                currentMood += risk[i]
                risksCount += 1
            } else {
                break
            }
        }
        //set currentMood in Child
        currentChild?.currentMood = currentMood / Float(risksCount)
        
        //calculate how many days away today
        let days = Calendar.current.dateComponents([.day], from: date[0] , to: Date()).day!
        currentChild?.twitterMissingDays = Int16(days)
        
        
        //calculate if need alert
        //alert algorithm
        //need to be replaced after demo
        if risk.count >= 3 {
            if (risk[0]<0 && risk[1]<0 && risk[2]<0){
                currentChild?.ifAlert = true
            } else {
                currentChild?.ifAlert = false
            }
        } else {
            currentChild?.ifAlert = false
        }
    }
    

    //Google ML Cloud Service Access Token Set and Get Risks from Google Analysis
    func gcRequest(text : String, since_id : String, create_date : String) {
        //Google ML Cloud Service Access Token
        let urlAuthen = "https://language.googleapis.com/v1/documents:analyzeSentiment?key=??????????";//please put your key for your Google Cloud Account instead
        
        //Parameters for Post Message
        let parameters: Parameters = [
            "encodingType": "UTF8",
            "document": [
                "type": "PLAIN_TEXT",
                "content": text,
            ]
        ]
        
        //Alamofire a Request to Google ML Cloud Server
        Alamofire.request(urlAuthen,method: .post, parameters: parameters,  encoding: JSONEncoding.default).responseJSON
            { (response:DataResponse) in
                switch response.result {
                    case .success(let value):
                        let jsonAuthen = JSON(value)
                        
                        //print(jsonAuthen) //test only
                        print("==========================")
                        print("twitter_id: \(since_id)")
                        print("create_time: \(create_date)")
                        print("twitter_content: \(text)")
                        print("magnitude: \(jsonAuthen["documentSentiment"]["magnitude"])")
                        print("score: \(jsonAuthen["documentSentiment"]["score"])")
                        print("\n")
                        //print(jsonAuthen) //test only
                        
                        //save chidName in Risk and update lastAccessDate in Child
                        //store twitterSinceID in Risk
                        //store postDate in Risk
                        //save magnitude and score in Risk
                        let date = create_date.toDate(dateFormat: "EEE MMM dd HH:mm:ss ZZZZZ yyyy")
                        let sinceid = Int64(since_id)
                        let m = Float("\(jsonAuthen["documentSentiment"]["magnitude"])")
                        let s = Float("\(jsonAuthen["documentSentiment"]["score"])")
                        self.saveChild(sinceID: sinceid!, date: Date())
                        self.saveRisk(name: (self.currentChild?.name)!, sinceID: sinceid!, postDate: date, magnitude: m!, score: s!)
                    
                    case .failure(let error):
                        print(error)
                        return
                    }
        }
        
    }
    
    //Twitter App Access Token Set and Get Post from Targetted Twitter User ID
    func retrieveTwitter(twitterId:String,sinceId:String?) {
        //Set Twitter APP Access Token
        let customerKey = "ZfyJo2mBTk1ZZELJRe7soNAyz"
        let customerSecret = "??????????????????" // Please instead of your secret from Twitter API
        
        //Set Parameters
        let keyValue = "\(customerKey):\(customerSecret)"
        let utf8strKey = keyValue.data(using: String.Encoding.utf8)
        let base64Encoded = utf8strKey!.base64EncodedString();
        let authen = "Basic \(String(describing: base64Encoded))";
        let urlAuthen = "https://api.twitter.com/oauth2/token";
        let urlTimeLine = "https://api.twitter.com/1.1/statuses/user_timeline.json";
        let headers = ["Authorization" : authen,
                       "Content-Type": "application/x-www-form-urlencoded"]
        let parameters: Parameters = ["grant_type": "client_credentials"]
        
        //Alamofire a Request to Twitter Server
        Alamofire.request(urlAuthen, method: .post, parameters: parameters,headers: headers).responseJSON
            { (response:DataResponse) in
                switch response.result {
                    case .success(let value):
                        let jsonAuthen = JSON(value)
                        let token = jsonAuthen["access_token"].description
                        print("Token: \(token)")
                        var parametersTimeLine : Parameters = Parameters();
                        parametersTimeLine["screen_name"] = twitterId;
                        if (sinceId != nil) {
                            parametersTimeLine["since_id"] = sinceId;
                        }
                    
                        //Send Posts to Google Natural Language Processing
                        let timeLineAuthen = "Bearer \(token)";
                        let headersTimeLine = ["Authorization" : timeLineAuthen]
                        Alamofire.request(urlTimeLine, parameters: parametersTimeLine,headers: headersTimeLine).responseJSON {
                                (response1:DataResponse) in
                                switch response1.result {
                                    case .success(let value):
                                        let json = JSON(value)
                                        for twitter in json.arrayValue {
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
    
    
    //Save Information of Risk in database
    func saveRisk(name: String, sinceID: Int64, postDate: Date, magnitude: Float, score: Float) -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Risk", in: context)
        let newRisk = NSManagedObject(entity: entity!, insertInto: context)
        
        //set all attributes
        newRisk.setValue(name, forKey: "childName")
        newRisk.setValue(sinceID, forKey: "twitterSinceID")
        newRisk.setValue(postDate, forKey: "postDate")
        newRisk.setValue(magnitude, forKey: "magnitude")
        newRisk.setValue(score, forKey: "score")
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    //Get Information of Risk in database
    //Sort and Return a Array
    //Current Date First
    func getRisks(name: String) -> [(Date, Float)]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Risk")
        
        fetchRequest.predicate = NSPredicate(format: "childName == %@", argumentArray: [name])
        
        var risks = [Date: Float]()
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 { // Atleast one was returned
                
                for n in 0..<(results!.count){
                    let date = results![n].value(forKey: "postDate")
                    let risk = results![n].value(forKey: "score")
                    risks.updateValue(risk as! Float, forKey: date as! Date)
                }
            }
        } catch {
            print("Fetch Failed in Risk: \(error)")
        }
        let newrisks = risks.sorted { firstDictionary, secondDictionary in
            let firstKey = firstDictionary.0
            let secondKey = secondDictionary.0
            return firstKey > secondKey
        }
        return newrisks
    }
    
    //Save Information of Child in database
    func saveChild(sinceID: Int64, date: Date) -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Child")
        
        fetchRequest.predicate = NSPredicate(format: "name == %@ && twitterSinceID < %@", argumentArray: [(currentChild?.name)!, sinceID])
        
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 { // Atleast one was returned
                results![0].setValue(sinceID, forKey: "twitterSinceID")
                results![0].setValue(date, forKey: "lastAccessDate")
            }
        } catch {
            print("Fetch Failed in Child: \(error)")
        }
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    
    
}

