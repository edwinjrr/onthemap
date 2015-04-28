//
//  Student.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/27/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit

struct Student {
    
    var firstName = ""
    var lastName = ""
    
    init(dictionary: [String : AnyObject]) {
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
    }
    
    static func studentsFromResults(results: [[String : AnyObject]]) -> [Student] {
        
        var students = [Student]()
        
        /* Iterate through array of dictionaries; each Movie is a dictionary */
        for result in results {
            students.append(Student(dictionary: result))
        }
        
        return students
    }
    
}
