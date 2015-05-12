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
    
    /* If the user decides to overwrite, the parameter will be set to "true", otherwise to "False", then the infoPostingViewController can choose to POST or update(PUT) the student location. */
    var studentLocationSubmitted: Bool!
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapStringTextFieldView.backgroundColor = UIColor(red: 0.20, green: 0.45, blue: 0.64, alpha: 1.0)
        
        mapStringTextField.delegate = self
        mediaURLTextField.delegate = self
    }

    @IBAction func findOnTheMap(sender: AnyObject) {
        
        if mapStringTextField.text.isEmpty {
            self.alertView("The address field is empty...")
        }
        else {
            self.studentMapString = self.mapStringTextField.text
            let regionRadius: CLLocationDistance = 2000
            var geocoder = CLGeocoder()
            
            //Forward Geocoding: From address to coordinates.
            geocoder.geocodeAddressString(studentMapString, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                if let placemark = placemarks?[0] as? CLPlacemark {
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, regionRadius, regionRadius)
                    self.locationMapView.setRegion(coordinateRegion, animated: true)
                    self.locationMapView.addAnnotation(MKPlacemark(placemark: placemark))
                    
                    //Getting the coordinates
                    self.studentLatitude = placemark.location.coordinate.latitude as Double
                    self.studentLongitude = placemark.location.coordinate.longitude as Double
                    
                    self.secondStepAppearanceSetup()
                }
                else {
                    self.alertView("Sorry, your address is not valid...")
                }
            })
        }
    }
    
    func alertView(message: String) {
        var alert = UIAlertController(title: "Oops!!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func secondStepAppearanceSetup() {
        self.view.backgroundColor = UIColor(red: 0.20, green: 0.45, blue: 0.64, alpha: 1.0)
        self.cancelButton.titleLabel?.textColor = UIColor.whiteColor()
        
        self.questionLabel.hidden = true
        self.mapStringTextField.hidden = true
        self.mapStringTextFieldView.hidden = true
        self.findOnTheMapButton.hidden = true
        
        self.mediaURLTextField.hidden = false
        self.locationMapView.hidden = false
        self.submitButton.hidden = false
    }
    
    // If the user is updating his location, the method will make a PUT request and if not, will make a POST request.
    @IBAction func submitStudentLocation(sender: AnyObject) {
        
        self.loadingView(true) //Show the user that the app is working with his request, disabling the "submit" button.
        
        if mediaURLTextField.text.isEmpty {
            self.loadingView(false)
            self.alertView("The URL field is empty...")
        }
        else {
            
            studentMediaURL = mediaURLTextField.text
          
            if verifyURL(studentMediaURL) {
                if self.studentLocationSubmitted == true {
                    Client.sharedInstance().updateStudentLocation(studentMapString, mediaURL: studentMediaURL, latitude: studentLatitude, longitude: studentLongitude, completionHandler: { (success, error) -> Void in
                        if success {
                            self.loadingView(false)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            self.loadingView(false)
                            self.alertView("Sorry, with couldn't update your location...")
                        }
                    })
                }
                else {
                    Client.sharedInstance().postStudentLocation(studentMapString, mediaURL: studentMediaURL, latitude: studentLatitude, longitude: studentLongitude, completionHandler: { (success, error) -> Void in
                        if success {
                            self.loadingView(false)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            self.loadingView(false)
                            self.alertView("Sorry, with couldn't submit your location...")
                        }
                    })
                }
                
            }
            else {
                self.loadingView(false)
                self.alertView("Sorry, your URL is not valid...")
            }
        }
    }
    
    //Show the user that the app is working with his request, disabling the "submit" button.
    func loadingView(state: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            if state {
                self.submitButton.enabled = false
                self.submitButton.alpha = 0.5
            }
            else {
                self.submitButton.enabled = true
                self.submitButton.alpha = 1.0
            }
        })
    }
    
    func verifyURL(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    @IBAction func cancelInfoPosting(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UITextFieldDelegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
