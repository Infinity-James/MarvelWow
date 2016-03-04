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
    
    private let APIParameterKey = "apikey"
    private let hashParameterKey = "hash"
    private let timestampParameterKey = "ts"
    
    private let publicAPIKey = "1fad7c8c49179fc7287b7a8d635a0483"
    
    //	MARK: Marvel API Client Errors
    enum MarvelAPIClientError: ErrorType {
        /// The query was previously made and is still in process.
        case QueryExists
    }
    
    //	MARK: Properties
    
    /// The URL session used to create our data tasks. Ideally this would be a constant (and would not be an implicitly unwrapped optional).
    /// However the initializer requires 'self' (because we want to be the delegate).
    private var session: NSURLSession!
    private let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    private let sessionQueue: NSOperationQueue = {
        let sessionQueue = NSOperationQueue()
        sessionQueue.name = "Marvel API Session Queue"
        return sessionQueue
    }()
    /// A store for an query completion closures mapping the URL of the query to the closure.
    private var queryCompletionClosures = [String: QueryCompleted]()
    
    
    
    //	MARK: Type Alias
    
    /// A closure that can be called when a query has received a response
    typealias QueryCompleted = () -> ()
    
    //	MARK: Initialization
    
    override init() {
        
        super.init()
        
        session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: sessionQueue)
    }
    
    //	MARK: API Communication
    
    /**
        Accepts a query object and fires it at Marvel's super awesome API.
    
        - Parameter query:      The query that Marvel need to handle (Captain America could probably get involved if it proves too difficult).
        - Parameter completion: Once Marvel answer our query (and they will because the good guys always win), this completion handler will be called.
     */
    func executeQuery(query: MarvelAPIQuery, completion: QueryCompleted) throws {
        //  create the URL for the API request
        let endpointURL = baseEndpointURL.URLByAppendingPathComponent(query.endpointAPIPath)
        let fullURL = endpointURL.URLByAppendingPathComponent(query.fullQueryPathComponent)
        
        //  if this query is already in process we throw the appropriate error, otherwise we store the completion closure
        let closureKey = fullURL.absoluteString
        if let _ = queryCompletionClosures[closureKey] {
            throw MarvelAPIClientError.QueryExists
        } else {
            queryCompletionClosures[closureKey] = completion
        }
        
        //  create the request and data task and then start it
        let URLRequest = authorizedURLRequest(fromURL: fullURL)
        let dataTask = session.dataTaskWithRequest(URLRequest)
        dataTask.resume()
    }
    
    //	MARK: Authorization
    
    private func authorizedURLRequest(fromURL URL: NSURL) -> NSURLRequest {
        
        let request = NSMutableURLRequest(URL: URL)
        //  all requests to Marvel are "GET"
        request.HTTPMethod = "GET"
        //  set a sensible timeout
        request.timeoutInterval = 20.0
        
        let parameters = [APIParameterKey: publicAPIKey]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
        } catch {
            fatalError("Setting the HTTP Body for authorization is not working: \(parameters)\nError: \(error)")
        }
        
        return request.copy() as! NSURLRequest
        
    }
}

//	MARK: NSURLSessionDataDelegate Functions

extension MarvelAPIClient: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
    }
}