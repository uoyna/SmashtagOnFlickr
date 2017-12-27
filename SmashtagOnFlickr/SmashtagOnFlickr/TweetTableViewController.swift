//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by yang le on 09/12/2017.
//  Copyright © 2017 AnyouJiang. All rights reserved.
//

import UIKit
import Twitter
import OAuthSwift
import SafariServices

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var oauthswift: OAuthSwift?
    
    private var tweets = [Array<Twitter.Tweet>]() {
        didSet{
            print(tweets)
        }
    }
    
    var searchText: String?{
        didSet{
            self.searchTextField?.text = self.searchText
            self.searchTextField?.resignFirstResponder()
            self.tweets.removeAll();
            self.tableView.reloadData()
            self.searchForTweets()
            self.title = self.searchText
        }
    }
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = self.searchText, !query.isEmpty {
            return Twitter.Request(search: query, count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    
    
    private func searchForTweets(){
        if let request = self.twitterRequest() {
            self.lastTwitterRequest = request
            request.fetchTweets {[weak self]  newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest{
                        self?.tweets.insert(newTweets, at: 0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension     
        
        let oauthswift = OAuth1Swift(
            consumerKey:    "85d23a8b9da1862a56238eddd354dbe6", //serviceParameters["consumerKey"]!,
            consumerSecret: "2b0d1c0a5c84c358", //serviceParameters["consumerSecret"]!,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = getURLHandler()
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "LearnFromPictures://oauth-callback/flickr")!,
            success: { credential, response, parameters in
                //self.showTokenAlert(name: serviceParameters["name"], credential: credential)
                //self.testFlickr(oauthswift, consumerKey: serviceParameters["consumerKey"]!)
                print("success")
        },
            failure: { error in
                print(error.description)
        }
        )
    }

    
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        #if os(iOS)
            if #available(iOS 9.0, *) {
                let handler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
                handler.presentCompletion = {
                    print("Safari presented")
                }
                handler.dismissCompletion = {
                    print("Safari dismissed")
                }
                handler.factory = { url in
                    let controller = SFSafariViewController(url: url)
                    // Customize it, for instance
                    if #available(iOS 10.0, *) {
                        //  controller.preferredBarTintColor = UIColor.red
                    }
                    return controller
                }
                
                return handler
            }
        #endif
        return OAuthSwiftOpenURLExternally.sharedInstance
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet{
            self.searchTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.searchTextField {
            self.searchText = self.searchTextField.text
        }
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tweets[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        // Configure the cell...
        let tweet: Tweet = self.tweets[indexPath.section][indexPath.row]
        //cell.textLabel?.text = tweet.text
        //cell.detailTextLabel?.text = tweet.user.name
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }

        return cell
    }
    
}
