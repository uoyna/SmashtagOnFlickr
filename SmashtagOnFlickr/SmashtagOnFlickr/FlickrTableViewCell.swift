//
//  FlickrTableViewCell.swift
//  SmashtagOnFlickr
//
//  Created by yang le on 04/01/2018.
//  Copyright © 2018 AnyouJiang. All rights reserved.
//

import UIKit

class FlickrTableViewCell: UITableViewCell {

    @IBOutlet weak var flickrPhoto: UIImageView!
    @IBOutlet weak var flickrCreated: UILabel!
    @IBOutlet weak var flickrOwner: UILabel!
    @IBOutlet weak var flickrDescription: UILabel!
    
    var flickr: Flickr?
    {
        didSet {
            self.updateUI()
        }
    }
    
    private var lastImageUrl: URL?
    
    private func updateUI(){
        self.flickrDescription?.text = self.flickr?.text
        if let imageUrl = self.flickr?.url_q {
            self.lastImageUrl = imageUrl
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: imageUrl) {
                [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                    if self?.lastImageUrl == imageUrl, let imageData = data{
                        DispatchQueue.main.async {
                            self?.flickrPhoto?.image = UIImage(data: imageData)
                        }
                }
            }
            task.resume()
        }
        else {
            self.flickrPhoto?.image = nil
        }
        
        if let owner = self.flickr?.ownerName {
            self.flickrOwner?.text = owner
        }
        
        if let datetaken = self.flickr?.datetaken {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(datetaken) > 60 * 60 * 24 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            self.flickrCreated?.text = formatter.string(from: datetaken)
        }
    }

}
