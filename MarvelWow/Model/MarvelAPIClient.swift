//
//  MarvelAPIClient.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Marvel API Client

/**
    `MarvelAPIClient`

    A native Swift client for querying Marvel's API.
 */
class MarvelAPIClient: NSObject {
    
}

//	MARK: NSURLSessionDataDelegate Functions

extension MarvelAPIClient: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
    }
}

//	MARK: Marvel API Query

/**
    `MarvelAPIQuery`

    A protocol conformed to by objects to be executed as a query to the Marvel API.
 */
protocol MarvelAPIQuery {
}

//	MARK: Marvel API Comic Book Query

/**
    `MarvelAPIComicBookQuery`

    Represents a query about comics books to Marvel's API.
    This allows for specifying the number of comic books to be fetched as well as the date range for those comic books.
 */
struct MarvelAPIComicBookQuery {
}