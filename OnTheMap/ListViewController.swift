//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/27/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.

import UIKit

class ListViewController: UITableViewController {
    
    var session: NSURLSession!
    
    var students: [StudentInformation] = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adding the bar button items of the navigation bar.
        let addLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "checkForStudentLocation")
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "getStudentsList")
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
        
        self.navigationItem.leftBarButtonItem = logoutButton
        self.navigationItem.rightBarButtonItems = [refreshButton, addLocationButton]

        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        self.getStudentsList()
    }
    
    func getStudentsList() {
        
        //Checking for internet connection first.
        if Reachability.isConnectedToNetwork() == true {
            Client.sharedInstance().getStudentsLocations() { (results, error) in
                if let results = results {
                    self.students = results
                    dispatch_async(dispatch_get_main_queue()) {
                        tableView?.reloadData()
                    }
                }
                else {
                    self.getStudentsListAlertView()
                }
            }
        } else {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    //If an error occurs downloading the students locations, the user can retry or cancel the request.
    func getStudentsListAlertView() {
        var alert = UIAlertController(title: nil, message: "Something happen trying to download the students locations.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: {action in
            self.getStudentsList()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
        
        //cell.textLabel!.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.textLabel!.text = student.fullname
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
        
        //Checking for internet connection first.
        if Reachability.isConnectedToNetwork() == true {
            Client.sharedInstance().queryingStudentLocation({(success, error) -> Void in
                if success {
                    self.overwriteAlertView()
                }
                else {
                    self.showInfoPostingView(false)
                }
            })
        } else {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
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
