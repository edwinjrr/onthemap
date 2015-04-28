//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Edwin Rodriguez on 4/27/15.
//  Copyright (c) 2015 Edwin Rodriguez. All rights reserved.
//

extension ParseClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: Access keys
        static let ParseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let BaseURLSecure : String = "https://api.parse.com/1/classes/"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "error"
        static let StatusCode = "status"
        
    }
    
}


