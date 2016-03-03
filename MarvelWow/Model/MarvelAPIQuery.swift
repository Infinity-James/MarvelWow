//
//  MarvelAPIQuery.swift
//  MarvelWow
//
//  Created by James Valaitis on 03/03/2016.
//  Copyright © 2016 &Beyond. All rights reserved.
//

//	MARK: Marvel API Query Parameter Keys Enum

/**
`MarvelAPIQueryParameterKeys`

Defines the parameters available when making a query to the Marvel API.
Making this an enum ensures safety for making a query with valid parameters.
*/
enum MarvelAPIQueryParameterKeys {
    
}

//	MARK: Marvel API Query Protocol

/**
`MarvelAPIQuery`

A protocol conformed to by objects to be executed as a query to the Marvel API.
*/
protocol MarvelAPIQuery {
    
    //	MARK: Properties
    
    /// The endpoint path component for this query.
    var endpointAPIPath: String { get }
    /// The query as a path component to be appended to the API endpoint.
    var fullQueryPathComponent: String { get }
}

//	MARK: Marvel API Comic Format Enum

/**
`MarvelAPIComicFormat`

Defines the type of comic formats which are available in a query.
Each case maps to it's representation as a URL parameter.
*/
enum MarvelAPIComicFormat: String {
    /// The standard comic book format.
    case Comic = "comic"
    /// A magazine.
    case Magazine = "magazine"
    /// Comics collected into a TPB.
    case TradePaperback = "trade paperback"
    /// Comics sold as a hardcover TPB.
    case Hardcover = "hard cover"
    /// I don't know what a Marvel digest is.
    case Digest = "digest"
    /// Marvel Graphic Novels, such as 'Marvels'.
    case GraphicNovel = "graphic novel"
    /// Comics sold digitally.
    case DigitalComic = "digital comic"
    /// Marvel comics released under the 'Infinite' imprint.
    case InfiniteComic = "infinite comic"
}

//	MARK: Marvel API Comic Format Type Enum

/**
`MarvelAPIComicFormatType`

Defines the format type for the comics requested in the query.
Each case maps to it's representation as a URL parameter.
*/
enum MarvelAPIComicFormatType: String {
    /// The stand alone comic.
    case Comic = "comic"
    /// A collection of the comics.
    case Collection = "collection"
}

//	MARK: Marvel API Comic Query Protocol

/**
`MarvelAPIComicQuery`

Builds on the MarvelAPIQuery as a query specifically about Marvel comics.
*/
protocol MarvelAPIComicQuery: MarvelAPIQuery {
    
    
    //	MARK: Properties
    
    /// The desired comic format.
    var comicFormat: MarvelAPIComicFormat { get }
    /// The desired comic format type.
    var comicFormatType: MarvelAPIComicFormatType { get }
}

extension MarvelAPIComicQuery {
    /// The API endpoint path for queries about Marvel comics.
    var endpointAPIPath: String { return "/v1/public/comics" }
    /// The comic query format and format type as a parameter for the query.
    var formatParameter: String { return "format=" + comicFormat.rawValue + "&formatType=" + comicFormatType.rawValue }
}

//	MARK: Marvel API Comic Book Query Struct

/**
`MarvelAPIComicBookQuery`

Represents a query about comics books to Marvel's API.
This allows for specifying the number of comic books to be fetched as well as the date range for those comic books.
*/
struct MarvelAPIComicBookQuery: MarvelAPIComicQuery {
    
    //	MARK: Constants
    
    let comicFormat = MarvelAPIComicFormat.Comic
    let comicFormatType = MarvelAPIComicFormatType.Comic
    
    //	MARK: Computed Properties
    
    var fullQueryPathComponent: String {
        return ""
    }
    
    //	MARK: Variable Properties
}