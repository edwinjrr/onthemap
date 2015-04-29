//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/27/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    var session: NSURLSession!
    
    var students: [Student] = [Student]()

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        ParseClient.sharedInstance().getStudents() { (results, error) in
            if let results = results {
                self.students = results
                dispatch_async(dispatch_get_main_queue()) {
                    tableView?.reloadData()
                }
            }
            else {
                println(error)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellReuseIdentifier = "StudentTableViewCell"
        let student = students[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        cell.textLabel!.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel!.text = student.mediaURL
        cell.imageView!.image = UIImage(named: "pin")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = students[indexPath.row]
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: student.mediaURL)!)
    }

    @IBAction func logOut(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
