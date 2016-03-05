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
    private let baseEndpoint = "https://gateway.marvel.com"
    
    private let APIParameterKey = "apikey"
    private let hashParameterKey = "hash"
    private let timestampParameterKey = "ts"
    
    private let publicAPIKey = "1fad7c8c49179fc7287b7a8d635a0483"
    private let privateAPIKey = "c686eb280010eaa2519c662752304ff50c3ef145"
    
    //	MARK: Marvel API Client Errors
    
    enum MarvelAPIClientError: ErrorType {
        /// The received JSON for the query was in an unexpected format.
        case InvalidJSON
        /// The URL for the query is not valid.
        case InvalidURL
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
    private var queryCompletionClosures = [NSURL: QueryCompleted]()
    /// Parameters that need to be added to a URL request to the Marvel servers.
    private var APIParameters: [String: String] {
        let timestamp = NSDate.timeIntervalSinceReferenceDate()
        let hashBase = String(timestamp) + privateAPIKey + publicAPIKey
        let parameters = [APIParameterKey: publicAPIKey,
            timestampParameterKey: String(timestamp),
            hashParameterKey: hashBase.md5]
        
        return parameters
    }
    
    
    
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
        let endpoint = baseEndpoint + query.endpointAPIPath + "?" + query.fullQueryPathComponent
        guard let endpointURL = NSURL(string: endpoint) else {
            throw MarvelAPIClientError.InvalidURL
        }
        
        //  create the request up top to get the URL we will use as the key
        let URLRequest = authorizedURLRequest(fromURL: endpointURL)
        guard let finalURL = URLRequest.URL else {
            throw MarvelAPIClientError.InvalidURL
        }
        
        //  if this query is already in process we throw the appropriate error, otherwise we store the completion closure
        if let _ = queryCompletionClosures[finalURL] {
            throw MarvelAPIClientError.QueryExists
        } else {
            queryCompletionClosures[finalURL] = completion
        }
        
        //  create the request and download task and then start it
        
        let downloadTask = session.downloadTaskWithRequest(URLRequest)
        downloadTask.resume()
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
            let resources = JSON.map { return T(JSON: $0)! }
            
            completion(resources: resources, error: error)
        }
    }
    
    //	MARK: Authorization
    
    private func authorizedURLRequest(fromURL URL: NSURL) -> NSURLRequest {
        
        //  create authenticating URL component and append it to the existing query
        let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false)!
        var authenticationComponentString = ""
        for (key, value) in APIParameters {
            authenticationComponentString += "\(key)=\(value)&"
        }
        components.query = (components.query ?? "") + "&" + authenticationComponentString
        
        let request = NSMutableURLRequest(URL: components.URL!)
        //  all requests to Marvel are "GET"
        request.HTTPMethod = "GET"
        //  set a sensible timeout
        request.timeoutInterval = 20.0
        
        return request.copy() as! NSURLRequest
        
    }
}

//	MARK: NSURLSessionDownloadDelegate Functions

extension MarvelAPIClient: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        //  If there was an error we print all of the relevant information
        if let error = error {
            print("Error occured whilst executing data task: \(error.localizedDescription)\nCode: \(error.code)\nReason: \(error.localizedFailureReason)")
            print("Original Request: \(task.originalRequest)")
            print("Response: \(task.response)")
            return
        }
        
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        //  we need a closure which maps to this task otherwise there's nothing to give the results to
        guard let URL = downloadTask.originalRequest?.URL,
            queryCompleted = queryCompletionClosures[URL] else {
                print("Completion closure not found download task: \(downloadTask)\nAborting early.")
                return
        }
        
        //  we need the data from this download task
        guard let data = NSData(contentsOfURL: location) else {
            print("Could not find data for download task: \(downloadTask)\nApparent Location: \(location)")
            return
        }
        
        //  we parse the data into a JSON object and call the completion closure with it
        let JSON: NSDictionary?
        do {
            JSON = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
        } catch {
            print("Error occured whilst trying to serialize JSON: \(error)")
            queryCompleted(JSON: nil, error: error)
            return
        }
        
        guard let dataJSON = JSON?["data"] as? NSDictionary,
            resultsJSON = dataJSON["results"] as? [JSONValue] else {
                print("JSON is not in expected format: \(JSON)")
                queryCompleted(JSON: nil, error: MarvelAPIClientError.InvalidJSON)
                return
        }
        
        
        
        //  everything went well
        queryCompleted(JSON: resultsJSON, error: nil)
    }
}

//	MARK: Cryptography

/**
    This extension allows for an easy way to hash a string using md5.
 */
extension String  {
    var md5: String {
        //  create the required objects for hashing the string
        let string = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let stringLength = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLength)
        
        //  hash the string passing our result pointer by reference
        CC_MD5(string!, stringLength, result)
        
        //  create a string from the resulting hash
        let hash = NSMutableString()
        for i in 0..<digestLength {
            hash.appendFormat("%02x", result[i])
        }
        
        //  deallocate the pointer
        result.dealloc(digestLength)
        
        return String(hash)
    }
}