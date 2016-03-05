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
typealias Identifier = Int
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

//	MARK: Constants

/**
    These need to be global constants because if they are computed properties on `MarvelAPIResource` they cannot be used within the initializer.
    This is because `self` cannot be used until all properties have been initialized.
 */

/// A key that can be used on JSON describing a resource to get the ID.
let MarvelAPIResourceIDKey = "id"
/// A key that can be used on JSON describing a resource to get the ID.
let MarvelAPIResourceURIKey = "resourceURI"
