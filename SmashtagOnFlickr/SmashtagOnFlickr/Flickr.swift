//
//  Flickr.swift
//  SmashtagOnFlickr
//
//  Created by yang le on 02/01/2018.
//  Copyright © 2018 AnyouJiang. All rights reserved.
//

import Foundation

extension NSDictionary {
    func string(forKeyPath keyPath: String) -> String? {
        return value(forKeyPath: keyPath) as? String
    }
}

public struct Flickr : CustomStringConvertible {
    
    public let id : String
    public let datetaken: Date
    public let ownerId : String
    public let ownerName : String
    public let title : String
    public let text: String
    public let url_q : URL
    public let url_z : URL
    
     public var description: String {
        return "Flickr id = \(self.id), ownerId = \(self.ownerId), owner_name = \(self.ownerName), title = \(self.title), description = \(self.text), url_q = \(self.url_q), url_z = \(self.url_z)"
    }
    
    init?(data: NSDictionary?)
    {
        guard
            let id = data?.string(forKeyPath: FlickrRequest.FlickrKey.id),
            let datetaken = data?.string(forKeyPath: FlickrRequest.FlickrKey.datetaken),
            let ownerId = data?.string(forKeyPath: FlickrRequest.FlickrKey.ownerId),
            let ownerName = data?.string(forKeyPath: FlickrRequest.FlickrKey.owner_name),
            let title = data?.string(forKeyPath: FlickrRequest.FlickrKey.title),
            let text = data?.string(forKeyPath: FlickrRequest.FlickrKey.description),
            let url_q = data?.string(forKeyPath: FlickrRequest.FlickrKey.url_q),
            let url_z = data?.string(forKeyPath: FlickrRequest.FlickrKey.url_z)
            else {
                return nil
        }
        
        guard
            let datetakenAsDate = self.flickrDateFormatter.date(from: datetaken),
            let url_qAsURL = URL(string: url_q),
            let url_zAsURL = URL(string: url_z)
        else {
            return nil
        }
        
        
        self.id = id
        self.datetaken = datetakenAsDate
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.title = title
        self.text = text
        self.url_q = url_qAsURL
        self.url_z = url_zAsURL
        
        
    }
    
    private let flickrDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
