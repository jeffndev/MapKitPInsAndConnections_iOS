//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/12/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit

class StudentsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataObserver {
    
    let CELL_ID = "StudentCell"
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StudentLocations.sharedInstance.registerObserver(self)
        if StudentLocations.sharedInstance.isPopulated() {
            tableView.reloadData()
        } else {
            StudentLocations.sharedInstance.fetchLocations()
        }
    }
    
    
    
    @IBAction func addNewPinAction(sender: UIBarButtonItem) {
        //TODO: just present the new view controller modally on this..
    }
    
    @IBAction func refreshDataAction(sender: UIBarButtonItem) {
        print("refresh...from TableView..")
        StudentLocations.sharedInstance.fetchLocations()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_ID)!
        let locations = StudentLocations.sharedInstance.locations()
        cell.textLabel?.text = "\(locations[indexPath.row].firstName) \(locations[indexPath.row].lastName)"
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocations.sharedInstance.locations().count
    }
    
    //DATA OBSERVER
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    func add(newItem: AnyObject, indexPath: NSIndexPath) {
        if let _ = newItem as? StudentLocation {
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
}
