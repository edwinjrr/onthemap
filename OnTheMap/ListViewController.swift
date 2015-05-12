//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/27/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.

import UIKit

class ListViewController: UITableViewController {
    
    var session: NSURLSession!
    
    var students: [Student] = [Student]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adding the bar button items of the navigation bar.
        let addLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "checkForStudentLocation")
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "getStudentList")
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
        
        self.navigationItem.leftBarButtonItem = logoutButton
        self.navigationItem.rightBarButtonItems = [refreshButton, addLocationButton]

        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        self.getStudentList()
    }
    
    func getStudentList() {
        Client.sharedInstance().getStudentsLocations() { (results, error) in
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
        
        //Setting up the TableViewCell
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

    //When the addLocationButton (Pin) gets pressed this method checks if the student already posted his location and acts accordingly.
    func checkForStudentLocation() {
        Client.sharedInstance().queryingStudentLocation({(success, error) -> Void in
            if success {
                self.overwriteAlertView()
            }
            else {
                self.showInfoPostingView(false)
            }
        })
    }
    
    //If the student already posted a location, a alertview will ask if him wants to overwrite the location with a new one.
    func overwriteAlertView() {
        var alert = UIAlertController(title: nil, message: "You have already posted a location!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: {action in
            self.showInfoPostingView(true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /* If the user decides to overwrite, the parameter will be set to "true", otherwise to "False", then the infoPostingViewController can choose to POST or update(PUT) the student location. */
    func showInfoPostingView(studentSubmitted: Bool) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
        controller.studentLocationSubmitted = studentSubmitted
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    func logout() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
