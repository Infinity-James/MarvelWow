//
//  MarvelAPIResource.swift
//  MarvelWow
//
//  Created by James Valaitis on 05/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Type Alias

/// A type which uniquely identifies a JSON resource.
typealias Identifier = String
/// A dictionary representing JSON.
typealias JSONValue = [String: AnyObject]

//	MARK: Marvel API Resource Protocol

/**
    `MarvelAPIResource`

    Defines an object that can be returned by the Marvel API.
 */
protocol MarvelAPIResource {
    
    //	MARK: Properties
    
    /// The unique identifier for this resource.
    var ID: Identifier { get }
    /// The URI at which this resource resides.
    var resourceURI: NSURL { get }
    
    //	MARK: Initialization
    
    /**
        Initializes a resource given some JSON.
    
        - Parameter JSON:   The JSON from which the resource should be initialized.
    
        - Returns:  An initialized Marvel resource.
     */
    init?(JSON: JSONValue)
}