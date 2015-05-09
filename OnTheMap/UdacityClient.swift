//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/23/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    
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
        
        /* Build the URL */
        let urlString = Constants.BaseURLSecure + "session"
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
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
        
        let urlString = Constants.BaseURLSecure + "users/\(userKey)"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let user = parsedResult["user"] as? [String: AnyObject] {
                    self.userFirstName = parsedResult["first_name"] as! String
                    self.userLastName = parsedResult["last_name"] as! String
                }
            }
        }
        task.resume()
    }

//    // MARK: - Helpers
//    
//    /* Helper: Substitute the key for the value that is contained within the method name */
//    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
//        if method.rangeOfString("{\(key)}") != nil {
//            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
//        } else {
//            return nil
//        }
//    }
    
//    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
//    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
//        
//        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
//            
//            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
//                
//                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
//                
//                return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
//            }
//        }
//        
//        return error
//    }
//    
//    /* Helper: Given raw JSON, return a usable Foundation object */
//    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
//        
//        var parsingError: NSError? = nil
//        
//        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
//        
//        if let error = parsingError {
//            completionHandler(result: nil, error: error)
//        } else {
//            completionHandler(result: parsedResult, error: nil)
//        }
//    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}