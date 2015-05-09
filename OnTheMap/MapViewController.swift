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
    
    var students: [Student] = [Student]()
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adding the bar button items of the navigation bar.
        let addLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "showInfoPostingView")
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "getStudentsList")
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
        
        self.navigationItem.leftBarButtonItem = logoutButton
        self.navigationItem.rightBarButtonItems = [refreshButton, addLocationButton]
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        self.getStudentsList()
    }
    
    func getStudentsList() {
        ParseClient.sharedInstance().getStudents() { (results, error) in
            if let results = results {
                self.students = results
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.reloadInputViews()
                }
                self.studentsLocations()
            }
            else {
                println(error)
            }
        }
    }
    
    func studentsLocations() {
        
        for dictionary in students {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(dictionary.latitude)
            let long = CLLocationDegrees(dictionary.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
    
    func logout() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showInfoPostingView() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
}
