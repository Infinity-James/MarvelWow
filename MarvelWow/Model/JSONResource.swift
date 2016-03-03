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
     
        - Parameter URLPath:    The path at which the data defined by this remote resource resides.
        - Parameter completion: A closure which will be executed upon completion the load (successful or otherwise).
     */
    mutating func load(URLPath: String, completion: RemoteResourceHandler) {
        
        //  cannot load an invalid URL
        guard let URL = NSURL(string: URLPath) else { fatalError("Invalid URL for resource: \(URLPath)") }
        
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