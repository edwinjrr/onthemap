//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/28/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var session: NSURLSession!
    
    var students: [StudentInformation] = [StudentInformation]()
    
    var annotations = [MKPointAnnotation]()
    
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
                        self.studentsLocationsAnnotations()
                        self.mapView.reloadInputViews()
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
    
    // Setting up the annotation properties to populate the annotations array.
    func studentsLocationsAnnotations() {
        
        //Remove old pins before adding new ones to avoid duplication.
        annotations = [MKPointAnnotation]()
        
        for dictionary in students {
            
            let lat = CLLocationDegrees(dictionary.latitude)
            let long = CLLocationDegrees(dictionary.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            // Here we create the annotation and set its coordinate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Placing the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Creating a view with a "right callout accessory view". 
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
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
