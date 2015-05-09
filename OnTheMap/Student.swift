//
//  Student.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/27/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit
//import MapKit

struct Student {
    
    var firstName: String!
    var lastName: String!
    var latitude: Double!
    var longitude: Double!
    var mediaURL: String!
    var mapString: String!
    var objectId: String!
    var uniqueKey: String!

    init(dictionary: [String : AnyObject]) {
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mediaURL = dictionary["mediaURL"] as! String
        mapString = dictionary["mapString"] as! String
        objectId = dictionary["objectId"] as! String
        uniqueKey = dictionary["uniqueKey"] as! String
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
