//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/29/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InfoPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var mapStringTextField: UITextField!
    @IBOutlet weak var mapStringTextFieldView: UIView!
    @IBOutlet weak var findOnTheMapButton: BorderedButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var submitButton: BorderedButton!
    
    var studentMapString: String!
    var studentMediaURL: String!
    var studentLatitude: Double!
    var studentLongitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapStringTextFieldView.backgroundColor = UIColor(red: 0.20, green: 0.45, blue: 0.64, alpha: 1.0)
        
        mapStringTextField.delegate = self
        mediaURLTextField.delegate = self
    }

    @IBAction func findOnTheMap(sender: AnyObject) {
        
        //Setup the appearance of the second step
        self.view.backgroundColor = UIColor(red: 0.20, green: 0.45, blue: 0.64, alpha: 1.0)
        self.cancelButton.titleLabel?.textColor = UIColor.whiteColor()
        
        self.questionLabel.hidden = true
        self.mapStringTextField.hidden = true
        self.mapStringTextFieldView.hidden = true
        self.findOnTheMapButton.hidden = true
        
        self.mediaURLTextField.hidden = false
        self.locationMapView.hidden = false
        self.submitButton.hidden = false
        
        self.locationWithString()
    }
    
    var annotations = [MKPointAnnotation]()
    
    func locationWithString() {
        
        studentMapString = mapStringTextField.text
        let regionRadius: CLLocationDistance = 1000
        
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(studentMapString, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
                self.locationMapView.setRegion(coordinateRegion, animated: true)
                self.locationMapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                self.studentLatitude = placemark.location.coordinate.latitude as Double
                self.studentLongitude = placemark.location.coordinate.longitude as Double
            }
            else {
                println("Error with the geocoding")
            }
        })
    }
    
    @IBAction func submitStudentLocation(sender: AnyObject) {
        
        studentMediaURL = mediaURLTextField.text
        
        if mediaURLTextField.text.isEmpty {
            println("MediaURL Text Field is empty!")
        }
        else {
            ParseClient.sharedInstance().postStudentLocation(studentMapString, mediaURL: studentMediaURL, latitude: studentLatitude, longitude: studentLongitude, completionHandler: { (success, error) -> Void in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    println("error")
                }
            })
        }
    }
    
    @IBAction func cancelInfoPosting(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
