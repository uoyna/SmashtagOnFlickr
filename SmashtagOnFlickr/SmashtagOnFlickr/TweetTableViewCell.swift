//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by yang le on 14/12/2017.
//  Copyright © 2017 AnyouJiang. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    
    var tweet: Twitter.Tweet? { didSet{ self.updateUI() } }
    

    private func updateUI(){
        self.tweetTextLabel?.text = self.tweet?.text
        self.tweetUserLabel?.text = self.tweet?.user.description
        
        if let profileImageURL = self.tweet?.user.profileImageURL {
            if let imageData = try? Data(contentsOf: profileImageURL){
                self.tweetProfileImageView?.image = UIImage(data: imageData)
            }
        } else {
            self.tweetProfileImageView?.image = nil
        }
        
        if let created = self.tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24 * 60 * 60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            self.tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            self.tweetCreatedLabel?.text = nil
        }
    }
}
