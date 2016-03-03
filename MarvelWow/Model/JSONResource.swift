//
//  JSONResource.swift
//  MarvelWow
//
//  Created by James Valaitis on 02/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Remote Resource

/**
    `RemoteResource`

    A protocol that defines a remotely obtained resource.
    Objects conforming to this protocol can be loaded.
*/
protocol RemoteResource {
}

/// A closure called upon the completion of the loading of a remote resource.
typealias RemoteResourceHandler = (data: NSData?, success: Bool) -> ()

extension RemoteResource {
    
    /**
        Loads the data defined by this resource.
     
        - Parameter URL:        The URL at which the data defined by this remote resource resides.
        - Parameter completion: A closure which will be executed upon completion the load (successful or otherwise).
     */
    func load(URL: NSURL, completion: RemoteResourceHandler) {
        
        //  create a task to download the resource
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL) { data, response, error in
            //  if we didn't get the data or there was an issue we fail out
            guard let HTTPResponse = response as? NSHTTPURLResponse, let data = data where error == nil else {
                print("Loading the remote resource failed.\n")
                if let error = error {
                    print("Error: \(error)")
                }
                completion(data: nil, success: false)
                return
            }
            
            //  if we get here, everything worked
            print("Response Code: \(HTTPResponse.statusCode)")
            
            completion(data: data, success: true)
        }
        
        //  start the download
        task.resume()
    }
}

/// A dictionary representing JSON.
typealias JSONValue = [String: AnyObject]

//	MARK: JSON Resource

/**
    `JSONResource`

    A protocol which defines a JSON resource.
*/
protocol JSONResource: RemoteResource {
    /// The host of the server where the JSON resides.
    var JSONHost: String { get }
    /// The path on the host for this JSON resource.
    var JSONPath: String { get }
    
    /**
        Processes the JSON data in place.
     
        - Parameter data:   The JSON data to be processed.
     
        - Returns:  Whether or not the JSON was processed successfully.
     */
    mutating func processJSON(data: NSData) -> Bool
}

/// A closure called upon the completion of the download and processing of JSON.
typealias JSONProcessed = (success: Bool) -> ()

extension JSONResource {
    /// Default the host name to this app's main API.
    var JSONHost: String { return "jsonplaceholder.typicode.com/" }
    /// Use the host and the path to generate a fully qualified URL.
    var JSONURL: NSURL {
        //  guard against an invalid JSON host
        guard let hostURL = NSURL(string: JSONHost) else { fatalError("The JSON Host for this resource is invalid: \(JSONHost)") }
        //  create the full URL from the host and the path
        let URL = hostURL.URLByAppendingPathComponent(JSONPath)
        return URL
    }
    
    /**
        Downloads the JSON and processes it.
     
        - Parameter completion: Called on the main queue once the JSON has been processed, either successfully or not.
     */
    mutating func loadJSON(completion: JSONProcessed?) {
        
        //  download the JSON
        load(JSONURL) { data, success in
            //  processing the result is down to the adopter of this protocol
            if let data = data where success {
                let success = self.processJSON(data)
                //  for convenience we call the completion on the main queue
                NSOperationQueue.mainQueue().addOperationWithBlock { completion?(success: success) }
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock { completion?(success: false) }
            }
        }
    }
}