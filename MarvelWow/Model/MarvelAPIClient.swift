//
//  MarvelAPIClient.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Marvel API Client Class

/**
    `MarvelAPIClient`

    A native Swift client for querying Marvel's API.
 */
class MarvelAPIClient: NSObject {
    
    //	MARK: Constants
    
    /// The base of API endpoint.
    private let baseEndpointURL = NSURL(string:"https://gateway.marvel.com/")!
    private let URLSession: NSURLSession = {
        let session = NSURLSession()
        return session
    }()
    
    //	MARK: Type Alias
    
    /// A closure that can be called when a query has received a response
    typealias QueryCompleted = () -> ()
    
    //	MARK: API Communication
    
    func executeQuery(query: MarvelAPIQuery, completion: QueryCompleted) {
        let endpointURL = baseEndpointURL.URLByAppendingPathComponent(query.endpointAPIPath)
        let fullURL = endpointURL.URLByAppendingPathComponent(query.fullQueryPathComponent)
    }
}

//	MARK: NSURLSessionDataDelegate Functions

extension MarvelAPIClient: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
    }
}