//
//  ResultsTableViewController.swift
//  MovieNight
//
//  Created by Christopher Bonuel on 11/17/16.
//  Copyright © 2016 Christopher Bonuel. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {
    
    var data: [String]!
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = data[indexPath.row]
     
         return cell
     }
}
