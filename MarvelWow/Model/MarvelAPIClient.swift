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
        /// The received JSON for the query was in an unexpected format.
        case InvalidJSON
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
    /// A dictionary that maps a URL to the data it has received thus far.
    private var receivedData = [NSURL: NSMutableData]()
    /// A store for an query completion closures mapping the URL of the query to the closure.
    private var queryCompletionClosures = [NSURL: QueryCompleted]()
    
    
    
    //	MARK: Type Alias
    
    /**
        A closure that can be called when a query has received a response.
    
        - Parameter JSON:   The parsed JSON object, if everything went well.
        - Parameter error:  An error, if something didn't go well.
     */
    typealias QueryCompleted = (JSON: [JSONValue]?, error: ErrorType?) -> ()
    
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
        if let _ = queryCompletionClosures[fullURL] {
            throw MarvelAPIClientError.QueryExists
        } else {
            queryCompletionClosures[fullURL] = completion
            receivedData[fullURL] = NSMutableData()
        }
        
        //  create the request and data task and then start it
        let URLRequest = authorizedURLRequest(fromURL: fullURL)
        let dataTask = session.dataTaskWithRequest(URLRequest)
        dataTask.resume()
    }
    
    /**
        Fetches the Marvel resources appropriate for a given query.
     
        - Parameter query:      The query to Marvel API.
        - Parameter completion: A closure that can be called when a query has received a response. (Called on the main queue).
             - resources: The requested resources, if everything went well.
             - error:     An error, if something didn't go well.
     */
    func fetchResourcesForQuery<T: MarvelAPIResource>(query: MarvelAPIQuery, completion: (resources: [T]?, error: ErrorType?) -> ()) throws {
        //  we throw any error thrown by executeQuery
        try executeQuery(query) { JSON, error in
            
            //  if we do not have our JSON we throw an error if it exists
            guard let JSON = JSON where error == nil else {
                completion(resources: nil, error: error)
                return
            }
            
            //  parse the JSON into resources
            let resources = JSON.map { return T(JSON: $0) }.filter { $0 != nil } as! [T]
            
            completion(resources: resources, error: error)
        }
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
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        guard let URL = dataTask.originalRequest?.URL,
            currentData = receivedData[URL] else {
            print("There is no URL associated with the data task: \(dataTask).")
            return
        }
        
        //  append the data the the data we have already received for this URL
        currentData.appendData(data)
        receivedData[URL] = currentData
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        //  we should only be dealing with data tasks, the task should have an associated URL, and that URL must map to a closure and received data
        guard let dataTask = task as? NSURLSessionDataTask,
            URL = dataTask.originalRequest?.URL,
            queryCompleted = queryCompletionClosures[URL],
            data = receivedData[URL]?.copy() as? NSData where error == nil else {
                print("Error occured when executing the NSURLSessionTask (\(task)): \(error)")
                return
        }
        
        //  we parse the data into a JSON object and call the completion closure with it
        let JSONObject: AnyObject?
        do {
            JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            print("Error occured whilst trying to serialize JSON: \(error)")
            queryCompleted(JSON: nil, error: error)
            return
        }
        
        guard let JSON = JSONObject as? [JSONValue] else {
            print("JSON is not in expected format: \(JSONObject)")
            queryCompleted(JSON: nil, error: MarvelAPIClientError.InvalidJSON)
            return
        }
        
        //  everything went well
        queryCompleted(JSON: JSON, error: nil)
    }
}