//
//  Student.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/27/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit
import MapKit

struct Student {
    
    var firstName = ""
    var lastName = ""
    var mediaURL = ""
    var mapString = ""
    var latitude = 0.0
    var longitude = 0.0
    
    init(dictionary: [String : AnyObject]) {
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        mapString = dictionary["mapString"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
    }
    
    static func studentsFromResults(results: [[String : AnyObject]]) -> [Student] {
        
        var students = [Student]()
        
        /* Iterate through array of dictionaries; each Student is a dictionary */
        for result in results {
            students.append(Student(dictionary: result))
        }
        
        return students
    }
    
}
