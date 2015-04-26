//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/23/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /* Constants for Udacity */
    let baseURLSecureString = "https://www.udacity.com/api/"
    
    /* Need these for login */
    var sessionID: String? = nil

}

// MARK: - Helper

extension AppDelegate {
    
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
    
}

