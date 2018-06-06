# DepressiveDetector
Depressive Detector is an iOS App for sentiment analysis of children's tweets. It aims to help parents automatically check if their children having a risk in their mental health. The main algorithm is to do sentiment analysis of children's tweets first and then provide an alert when the results are continuing negative for a long period (like a week) or have a clear trend of decrease at the same period. Those results will be recorded in the phone, but no content of tweets will be stored. The visualisation of weekly and monthly results is provided in the app. Emoji and colourful icons are used to indicate different levels of positive and negative mental health conditions. Twitter API (2018) is used for retrieving children's tweets. And Google ML Cloud Engine is used for sentiment analysis.  In future, online server with sentiment analysis engine in Python will be preferred for this app. The research of detecting depressive sentiments is another important step to enhance the accuracy and efficiency of this app.

## Apple Frameworks
This app was programmed in Swift. Only Foundation, Data Core, UIKit Apple libraries were used. Alamofire and SwiftyJSON from CocoaPods were imported to easily launch Get/Post HTTP requests to Twitter API and Google ML Engine. In the visualisation, partial codes from Nguyen Vu Nhat Minh's beautiful bar chart were merged into this app to display bar charts. The structure of this app is simple and focused on TableView. The coding hence can be easily varied to suit a commercial product.

## Launch Screen
![Preview](https://cdn.rawgit.com/nezha3/DepressiveDetector/master/image/launch.png)

## Child Panel:
![Preview](https://cdn.rawgit.com/nezha3/DepressiveDetector/master/image/childpanel.png)


## Display of Sentiment Analysis:
![Preview](https://cdn.rawgit.com/nezha3/DepressiveDetector/master/image/mood1.png)
![Preview](https://cdn.rawgit.com/nezha3/DepressiveDetector/master/image/mood2.png)


## Functionality to add new child:
![Preview](https://cdn.rawgit.com/nezha3/DepressiveDetector/master/image/addnewchild1.png)
![Preview](https://cdn.rawgit.com/nezha3/DepressiveDetector/master/image/addnewchild2.png)


## Future Works
I plan to build an online server to do the sentiment analysis, then submit this app to Apple App Store. If possible, I will construct a corresponding app in Android.
