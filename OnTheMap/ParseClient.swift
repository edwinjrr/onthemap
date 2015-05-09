//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/27/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func getStudents(completionHandler: (result: [Student]?, error: String?) -> Void) {
        
        /* 1. Set the parameters */
        let methodParameters = [
            "limit": 50
        ]
        
        /* 2. Build the URL */
        let urlString = Constants.BaseURLSecure + "StudentLocation" + escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-Api-Key")
        
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
        
        /* 2. Build the URL */
        let urlString = Constants.BaseURLSecure + "StudentLocation"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-Api-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(Constants.UniqueKey)\", \"firstName\": \"\(Constants.FirstName)\", \"lastName\": \"\(Constants.LastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
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
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }

}
