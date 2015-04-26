//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/23/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: URLs
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "error"
        static let StatusCode = "status"
        
        // MARK: Authorization
        static let SessionID = "session"
        
        // MARK: Account
        static let UserID = "id"
    
    }

}
