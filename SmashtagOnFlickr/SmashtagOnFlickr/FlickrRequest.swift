//
//  FlickrRequest.swift
//  SmashtagOnFlickr
//
//  Created by yang le on 02/01/2018.
//  Copyright © 2018 AnyouJiang. All rights reserved.
//

import Foundation
import OAuthSwift
import SafariServices


public class FlickrRequest : NSObject{

    static var oauthswift: OAuth1Swift?  //shared among requests
    
    struct FlickrKey{
        static let photo = "photos.photo"
        static let id = "id"
        static let datetaken = "datetaken"
        static let ownerId = "owner"
        static let owner_name = "ownername"
        static let title = "title"
        static let description = "description._content"
        static let url_q = "url_q"
        static let url_z = "url_z"
    }
    

    var requester: UIViewController
    var queryText: String
    
    public let consumerKey = "85d23a8b9da1862a56238eddd354dbe6"
    public let consumerSecret = "2b0d1c0a5c84c358"
    
    public typealias PropertyList = Any
    
    // designated initializer
    public init(_ query: String, _ requester: UIViewController) {
        self.queryText = query
        self.requester = requester
    }
    
    // debug println with identifying prefix
    private func log(_ whatToLog: Any) {
        debugPrint("FlickrRequest: \(whatToLog)")
    }
    
    public func fetchFlickrs(_ handler: @escaping (PropertyList?) -> Void) {
        performFlickrRequest(handler)
    }
    
    private func performFlickrRequest(_ handler: @escaping (PropertyList?) -> Void){
        if FlickrRequest.oauthswift == nil {
            let oauthswift = OAuth1Swift(
                consumerKey: self.consumerKey, //serviceParameters["consumerKey"]!,
                consumerSecret: self.consumerSecret, //serviceParameters["consumerSecret"]!,
                requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
                authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
                accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
            )
            FlickrRequest.oauthswift = oauthswift
            oauthswift.authorizeURLHandler = getURLHandler()
            let _ = oauthswift.authorize(
                withCallbackURL: URL(string: "SmashtagOnFlickr://oauth-callback/flickr")!,
                success: { credential, response, parameters in
                    self.log("success in oauthentication, next is to fetch phones from flickr....")
                    self.fetch(oauthswift, consumerKey: self.consumerKey, queryText: self.queryText, handler: handler)
            },
                failure: { error in
                    print(error.description)
            }
            )
        } else
        {
            self.fetch(FlickrRequest.oauthswift!, consumerKey: self.consumerKey, queryText: self.queryText, handler: handler)

        }
    }
    
    private func fetch (_ oauthswift: OAuth1Swift, consumerKey: String, queryText: String, handler: @escaping (PropertyList?) -> Void) {
        let url :String = "https://api.flickr.com/services/rest/"
        let parameters :Dictionary = [
            "method"         : "flickr.photos.search",
            "api_key"        : consumerKey,
            "text"           : queryText, //"128483205@N08",
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "date_taken,owner_name,description,url_q,url_z"
        ]
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: { response in
                let jsonDict = try? response.jsonObject()
                print(jsonDict as Any)
                handler(jsonDict as Any);
        },
            failure: { error in
                print(error)
        }
        )
    }
    
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        #if os(iOS)
            if #available(iOS 9.0, *) {
                let handler = SafariURLHandler(viewController: self.requester, oauthSwift: FlickrRequest.oauthswift!)
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
    
}
