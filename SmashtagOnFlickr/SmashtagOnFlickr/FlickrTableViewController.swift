//
//  FlickrTableViewController.swift
//  SmashtagOnFlickr
//
//  Created by yang le on 02/01/2018.
//  Copyright © 2018 AnyouJiang. All rights reserved.
//

import UIKit
import OAuthSwift

class FlickrTableViewController: UITableViewController, UITextFieldDelegate{
    
    private var flickrs = [Array<Flickr>]() {
        didSet{
            if(self.flickrs.count > 0){
                for flickr in self.flickrs[0]
                {
                    print(flickr)
                }
            }
        }
    }
    
    var searchText: String?{
        didSet{
            self.searchTextField?.text = self.searchText
            self.searchTextField?.resignFirstResponder()
            self.flickrs.removeAll()
            self.tableView.reloadData()
            self.searchForFlickrs()
            self.title = self.searchText
        }
    }
    
    private var lastFickrRequest: FlickrRequest?
    
    private func searchForFlickrs() {
        if let request = self.flickrRequest(){
            self.lastFickrRequest = request
            request.fetchFlickrs { [weak self] flickrs in
            //%print(flickrs as Any)
                DispatchQueue.main.async {
                    if request == self?.lastFickrRequest
                    {
                        if let photos = (flickrs as? NSDictionary)?.value(
                            forKeyPath: FlickrRequest.FlickrKey.photo) as? NSArray{
                            var flickrArray = Array<Flickr>()
                            for photo in photos {
                                if let flickr = Flickr(data: photo as? NSDictionary) {
                                    flickrArray.append(flickr)
                                }
                            }
                            self?.flickrs.insert(flickrArray, at: 0)
                            self?.tableView.insertSections([0], with: .fade)

                        }
                    }
                }

                
            }
        }
    }
    
    private func flickrRequest() -> FlickrRequest? {
        if let query = self.searchText, !query.isEmpty {
            return FlickrRequest(query, self)
        }
        return nil
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.searchText = "Stanford";

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.flickrs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.flickrs[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flickr", for: indexPath)

        if(indexPath.section < self.flickrs.count && indexPath.row < self.flickrs[indexPath.section].count){
            let flickr = self.flickrs[indexPath.section][indexPath.row]
            if let flickrCell = cell as? FlickrTableViewCell {
                flickrCell.flickr = flickr
            }
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
