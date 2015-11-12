//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by Jeff Newell on 11/12/15.
//  Copyright © 2015 Jeff Newell. All rights reserved.
//

import UIKit

class StudentsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let CELL_ID = "StudentCell"
    
    var locations: [StudentLocation]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations(false)
    }
    
    func loadLocations(doRefresh: Bool) {
        locations = ParseProvider.getSharedStudentLocations()
        ParseProvider.fetchStudentLocations(doRefresh) { (success, errMsg) in
            if success == true {
                dispatch_async(dispatch_get_main_queue()) {
                    self.locations = ParseProvider.getSharedStudentLocations()
                    self.tableView.reloadData()
                }
            } else {
                //TODO: err reporting?? user feedback
                print(errMsg)
            }
        }
    }
    
    
    @IBAction func addNewPinAction(sender: UIBarButtonItem) {
        //TODO:
    }
    
    @IBAction func refreshDataAction(sender: UIBarButtonItem) {
        loadLocations(true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_ID)!
        cell.textLabel?.text = "\(locations![indexPath.row].firstName) \(locations![indexPath.row].lastName)"
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseProvider.getSharedStudentLocations().count
    }
    
}
