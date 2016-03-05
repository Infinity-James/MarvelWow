//
//  MarvelComic.swift
//  MarvelWow
//
//  Created by James Valaitis on 05/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

import Foundation

//	MARK: Marvel Comics Struct

/**
    `MarvelComic`

    A resource from the Marvel API that represents a comic book.
 */
struct MarvelComic: MarvelAPIResource {
    
    //	MARK: Properties - Resource
    
    /// The unique identifier for this comic.
    let ID: Identifier
    /// The canonical URL identifier for this comic.
    let resourceURI: NSURL
    
    //	MARK: Properties - Comic
    
    /// The title of the comic.
    let title: String
    /// The URL pointing to the thumbnail of the comic.
    let thumbnailURL: NSURL?
    
    //	MARK: Initialization
    
    init?(JSON: JSONValue) {
        
        //  a comic book cannot exist without an ID or resource URI
        guard let identifier = JSON[MarvelAPIResourceIDKey] as? Identifier, URIString = JSON[MarvelAPIResourceURIKey] as? String, URI = NSURL(string: URIString) else {
            print("Expected a valid identifier and resource URI in JSON: \(JSON)")
            return nil
        }
        
        ID = identifier
        resourceURI = URI
        
        //  pull the comic specific properties starting with the title
        
        guard let comicTitle = JSON["title"] as? String else {
            print("What is a comic without a title? Title missing in JSON: \(JSON)")
            return nil
        }
        
        title = comicTitle
        
        //  get the URL for the thumbnail of the comic if it exists
        
        if let thumbnail = JSON["thumbnail"] as? JSONValue,
            thumbnailPath = thumbnail["path"] as? String,
            thumbnailExtension = thumbnail["extension"] as? String {
                thumbnailURL = NSURL(string: thumbnailPath + "." + thumbnailExtension)
        } else {
            thumbnailURL = nil
        }
    }
}