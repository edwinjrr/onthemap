//
//  Client.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/23/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import Foundation

class Client : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    var userKey: String!
    var userFirstName: String!
    var userLastName: String!
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func postSession(username: String, password: String, completionHandler: (success: Bool, error: String?) -> Void) {
        
        /* Create a session */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
            
                /* Parse the data */
                var parsingError: NSError? = nil
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Use the data */
                if let status_code = parsedResult["status"] as? Int {
                    completionHandler(success: false, error: "Invalid Login Credentials")
                } else {
                    if let userAccount = parsedResult["account"] as? [String : AnyObject] {
                        self.userKey = userAccount["key"] as! String
                        self.getPublicUserData()
                        completionHandler(success: true, error: nil)
                    }
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
    }
    
    func getPublicUserData() {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userKey)")!)

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let user = parsedResult["user"] as? [String: AnyObject] {
                    self.userFirstName = user["first_name"] as! String
                    self.userLastName = user["last_name"] as! String
                }
            }
        }
        task.resume()
    }
    
    func getStudentsLocations(completionHandler: (result: [Student]?, error: String?) -> Void) {
        
        /* 1. Set the parameters */
        let methodParameters = [
            "limit": 50
        ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation" + escapedParameters(methodParameters))!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-Api-Key")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                //println(parsedResult)
                
                /* 6. Use the data! */
                if let error = parsingError {
                    completionHandler(result: nil, error: "Could not find students")
                } else {
                    if let results = parsedResult["results"] as? [[String : AnyObject]] {
                        
                        var students = Student.studentsFromResults(results)
                        
                        completionHandler(result: students, error: nil)
                        
                    } else {
                        println("Could not find results in \(parsedResult)")
                    }
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    func postStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, error: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-Api-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(userFirstName)\", \"lastName\": \"\(userLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Use the data */
                if let status_code = parsedResult["status"] as? Int {
                    completionHandler(success: false, error: "Could not submit student location.")
                } else {
                    completionHandler(success: true, error: nil)
                }
            }
        }
        
        /* Start the request */
        task.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        
        return Singleton.sharedInstance
    }
}