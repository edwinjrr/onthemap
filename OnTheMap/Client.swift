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
    
    //Data of the StudentLocation object used by the APIs.
    var userKey: String!
    var objectID: String!
    var userFirstName: String!
    var userLastName: String!
    var facebookAccessToken: String!
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //MARK: Udacity API.
    
    func postSessionWithUdacityCredentials(username: String, password: String, completionHandler: (success: Bool, error: String?) -> Void) {
        
        /* Configuring the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Making the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(success: false, error: "Invalid Login Credentials")
            } else {
            
                /* Parsing the data */
                var parsingError: NSError? = nil
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Using the data */
                if let userAccount = parsedResult["account"] as? [String : AnyObject] {
                    self.userKey = userAccount["key"] as! String
                    self.getUdacityPublicUserData()
                    completionHandler(success: true, error: nil) }
                else {
                    completionHandler(success: false, error: "Invalid Login Credentials")
                }
            }
        }
        
        /* Starting the request */
        task.resume()
        
    }
    
    func getUdacityPublicUserData() {
        
        /* Configuring the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userKey)")!)

        /* Making the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                
                /* Parsing the data */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Using the data */
                if let user = parsedResult["user"] as? [String: AnyObject] {
                    self.userFirstName = user["first_name"] as! String
                    self.userLastName = user["last_name"] as! String
                }
            }
        }
        /* Starting the request */
        task.resume()
    }
    
    func postSessionWithFacebookAuthentication(facebookAccessToken: String, completionHandler: (success: Bool, error: String?) -> Void) {
        
        /* Configuring the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(facebookAccessToken)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Making the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completionHandler(success: false, error: "Could not submit student location.")
            } else {
                
                /* Parsing the data */
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Using the data */
                if let userAccount = parsedResult["account"] as? [String: AnyObject] {
                    self.userKey = userAccount["key"] as! String
                    self.getUdacityPublicUserData()
                    completionHandler(success: true, error: nil)
                } else {
                    completionHandler(success: false, error: "Could not submit student location.")
                }
            }
        }
        /* Starting the request */
        task.resume()
    }
    
    //MARK: Parse API.
    
    func getStudentsLocations(completionHandler: (result: [StudentInformation]?, error: String?) -> Void) {
        
        /* Setting the parameters */
        let methodParameters = [
            "limit": 100
        ]
        
        /* Configuring the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation" + escapedParameters(methodParameters))!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-Api-Key")
        
        /* Making the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: "Could not find students")
            } else {
                
                /* Parsing the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Using the data! */
                if let error = parsingError {
                    completionHandler(result: nil, error: "Could not find students")
                } else {
                    if let results = parsedResult["results"] as? [[String : AnyObject]] {
                        
                        var students = StudentInformation.studentsFromResults(results)
                        
                        completionHandler(result: students, error: nil)
                        
                    } else {
                        completionHandler(result: nil, error: "Could not find students")
                    }
                }
            }
        }
        /* Starting the request */
        task.resume()
    }
    
    func postStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, error: String?) -> Void) {
        
        /* Configuring the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-Api-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(userFirstName)\", \"lastName\": \"\(userLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Making the request */
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(success: false, error: "Could not submit student location.")
            } else {
                
                /* Parsing the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Using the data */
                if let status_code = parsedResult["status"] as? Int {
                    completionHandler(success: false, error: "Could not submit student location.")
                } else {
                    completionHandler(success: true, error: nil)
                }
            }
        }
        /* Starting the request */
        task.resume()
    }
    
    func queryingStudentLocation(completionHandler: (success: Bool, error: String?) -> Void) {
  
        /* Configuring the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(userKey)%22%7D")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* Making the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if let error = error {
                completionHandler(success: false, error: "Could not find student location.")
            } else {
                
                /* Parsing the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Using the data */
                if let results = parsedResult["results"] as? [[String : AnyObject]] {
                    self.objectID = results[0]["objectId"] as! String
                    completionHandler(success: true, error: nil)
                }
                else {
                    completionHandler(success: false, error: "Could not find student location.")
                }
                
            }
        }
        /* Starting the request */
        task.resume()
    }
    
    func updateStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, error: String?) -> Void) {
        
        /* Configuring the request */
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation/\(objectID)")!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(userFirstName)\", \"lastName\": \"\(userLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Making the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if let error = error {
                completionHandler(success: false, error: "Could not update student location.")
            } else {
                
                /* Parsing the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                /* Using the data */
                if let result = parsedResult["updatedAt"] as? String {
                    completionHandler(success: true, error: nil)
                } else {
                    completionHandler(success: false, error: "Could not update student location.")
                }
            }
        }
        /* Starting the request */
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